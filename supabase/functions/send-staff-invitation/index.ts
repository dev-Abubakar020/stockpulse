import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(
  body: Record<string, unknown>,
  status = 200,
) {
  return new Response(
    JSON.stringify(body),
    {
      status,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json",
      },
    },
  );
}

function escapeHtml(value: string) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders,
    });
  }

  if (req.method !== "POST") {
    return jsonResponse(
      { error: "Method not allowed" },
      405,
    );
  }

  try {
    // ---------------------------------------------------------
    // Environment variables
    // ---------------------------------------------------------

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get(
      "SUPABASE_SERVICE_ROLE_KEY",
    );
    const resendApiKey = Deno.env.get("RESEND_API_KEY");

    if (!supabaseUrl || !serviceRoleKey) {
      throw new Error(
        "Supabase environment variables are missing.",
      );
    }

    if (!resendApiKey) {
      throw new Error(
        "RESEND_API_KEY is not configured.",
      );
    }

    // ---------------------------------------------------------
    // Verify Authorization header
    // ---------------------------------------------------------

    const authHeader = req.headers.get("Authorization");

    if (!authHeader) {
      return jsonResponse(
        { error: "Authentication required." },
        401,
      );
    }

    // Admin client:
    // used only after manually verifying authenticated user.
    const supabaseAdmin = createClient(
      supabaseUrl,
      serviceRoleKey,
      {
        auth: {
          persistSession: false,
          autoRefreshToken: false,
        },
      },
    );

    // Verify JWT and obtain actual authenticated user
    const token = authHeader.replace(/^Bearer\s+/i, "");

    if (!token) {
      return jsonResponse(
        { error: "Invalid authorization token." },
        401,
      );
    }

    const {
      data: { user },
      error: userError,
    } = await supabaseAdmin.auth.getUser(token);

    if (userError || !user) {
      return jsonResponse(
        { error: "Invalid or expired session." },
        401,
      );
    }

    // ---------------------------------------------------------
    // Read body
    // ---------------------------------------------------------

    const body = await req.json();

    const invitationId =
      typeof body?.invitationId === "string"
        ? body.invitationId.trim()
        : "";

    if (!invitationId) {
      return jsonResponse(
        { error: "Invitation ID is required." },
        400,
      );
    }

    // ---------------------------------------------------------
    // Find invitation
    //
    // IMPORTANT:
    // invited_by = user.id means owner can only send an
    // invitation that they actually created.
    // ---------------------------------------------------------

    const {
      data: invitation,
      error: invitationError,
    } = await supabaseAdmin
      .from("staff_invitations")
      .select(`
        id,
        shop_id,
        email,
        token,
        status,
        invited_by,
        expires_at
      `)
      .eq("id", invitationId)
      .eq("invited_by", user.id)
      .maybeSingle();

    if (invitationError) {
      console.error(
        "Invitation lookup error:",
        invitationError,
      );

      return jsonResponse(
        { error: "Unable to load invitation." },
        500,
      );
    }

    if (!invitation) {
      return jsonResponse(
        {
          error:
            "Invitation not found or you are not allowed to send it.",
        },
        404,
      );
    }

    // ---------------------------------------------------------
    // Invitation status checks
    // ---------------------------------------------------------

    if (invitation.status !== "pending") {
      return jsonResponse(
        {
          error: `Invitation is already ${invitation.status}.`,
        },
        400,
      );
    }

    const expiresAt = new Date(invitation.expires_at);

    if (
      Number.isNaN(expiresAt.getTime()) ||
      expiresAt.getTime() <= Date.now()
    ) {
      // Keep DB status consistent
      await supabaseAdmin
        .from("staff_invitations")
        .update({
          status: "expired",
        })
        .eq("id", invitation.id)
        .eq("status", "pending");

      return jsonResponse(
        { error: "This invitation has expired." },
        400,
      );
    }

    // ---------------------------------------------------------
    // Verify requester is STILL active owner of same shop
    // ---------------------------------------------------------

    const {
      data: membership,
      error: membershipError,
    } = await supabaseAdmin
      .from("shop_members")
      .select("shop_id, role, is_active")
      .eq("user_id", user.id)
      .eq("shop_id", invitation.shop_id)
      .eq("role", "owner")
      .eq("is_active", true)
      .maybeSingle();

    if (membershipError) {
      console.error(
        "Membership lookup error:",
        membershipError,
      );

      return jsonResponse(
        { error: "Unable to verify shop ownership." },
        500,
      );
    }

    if (!membership) {
      return jsonResponse(
        {
          error:
            "Only the active shop owner can send this invitation.",
        },
        403,
      );
    }

    // ---------------------------------------------------------
    // Load shop
    // ---------------------------------------------------------

    const {
      data: shop,
      error: shopError,
    } = await supabaseAdmin
      .from("shops")
      .select("id, shopename")
      .eq("id", invitation.shop_id)
      .maybeSingle();

    if (shopError) {
      console.error("Shop lookup error:", shopError);

      return jsonResponse(
        { error: "Unable to load shop information." },
        500,
      );
    }

    if (!shop) {
      return jsonResponse(
        { error: "Shop not found." },
        404,
      );
    }

    const shopName =
      shop.shopename?.trim() || "StockPulse Shop";

    // ---------------------------------------------------------
    // Invitation URL
    // ---------------------------------------------------------
    //
    // Replace this with StockPulse's actual App Link domain.
    //
    // Example:
    // https://stockpulse.com/staff-invite?token=...
    //
    // Do NOT put invitation ID here.
    // claim_staff_invitation() requires the random token.
    // ---------------------------------------------------------

    const appLinkDomain = Deno.env.get(
      "STOCKPULSE_APP_LINK_DOMAIN",
    );

    if (!appLinkDomain) {
      throw new Error(
        "STOCKPULSE_APP_LINK_DOMAIN is not configured.",
      );
    }

    const baseUrl = appLinkDomain.replace(/\/+$/, "");

    const inviteUrl =
      `${baseUrl}/staff-invite?token=${
        encodeURIComponent(invitation.token)
      }`;

    // ---------------------------------------------------------
    // Escape dynamic HTML values
    // ---------------------------------------------------------

    const safeShopName = escapeHtml(shopName);
    const safeInviteUrl = escapeHtml(inviteUrl);

    // ---------------------------------------------------------
    // Send with Resend
    // ---------------------------------------------------------

    const resendResponse = await fetch(
      "https://api.resend.com/emails",
      {
        method: "POST",

        headers: {
          "Authorization": `Bearer ${resendApiKey}`,
          "Content-Type": "application/json",
        },

        body: JSON.stringify({
          // Replace domain after verifying it in Resend.
          from:
            "StockPulse <noreply@rishtajourney.com>",

          to: [invitation.email],

          subject:
            `You've been invited to join ${shopName}`,

          html: `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  >
</head>

<body
  style="
    margin:0;
    padding:0;
    background:#F8FAFF;
    font-family:Arial,sans-serif;
    color:#0F172A;
  "
>
  <div
    style="
      max-width:600px;
      margin:0 auto;
      padding:32px 16px;
    "
  >
    <div
      style="
        background:#FFFFFF;
        border:1px solid #E2E8F0;
        border-radius:16px;
        padding:32px;
      "
    >

      <div
        style="
          font-size:24px;
          font-weight:700;
          color:#3D7BFF;
          margin-bottom:24px;
        "
      >
        StockPulse
      </div>

      <h2
        style="
          margin:0 0 16px;
          font-size:22px;
          color:#0F172A;
        "
      >
        You're invited!
      </h2>

      <p
        style="
          margin:0 0 12px;
          font-size:15px;
          line-height:1.6;
          color:#475569;
        "
      >
        You have been invited to join
        <strong>${safeShopName}</strong>
        as a staff member on StockPulse.
      </p>

      <p
        style="
          margin:0 0 24px;
          font-size:15px;
          line-height:1.6;
          color:#475569;
        "
      >
        Create your StockPulse account using this same
        email address to accept the invitation.
      </p>

      <a
        href="${safeInviteUrl}"
        style="
          display:inline-block;
          background:#3D7BFF;
          color:#FFFFFF;
          text-decoration:none;
          padding:13px 24px;
          border-radius:10px;
          font-size:15px;
          font-weight:600;
        "
      >
        Join StockPulse
      </a>

      <p
        style="
          margin:24px 0 0;
          font-size:13px;
          line-height:1.5;
          color:#64748B;
        "
      >
        This invitation expires on
        ${expiresAt.toUTCString()}.
      </p>

      <p
        style="
          margin:12px 0 0;
          font-size:13px;
          line-height:1.5;
          color:#64748B;
        "
      >
        If you were not expecting this invitation,
        you can safely ignore this email.
      </p>

    </div>
  </div>
</body>
</html>
          `,
        }),
      },
    );

    const resendData = await resendResponse.json();

    if (!resendResponse.ok) {
      console.error(
        "Resend error:",
        resendData,
      );

      return jsonResponse(
        {
          error: "Unable to send invitation email.",
          details: resendData,
        },
        502,
      );
    }

    // ---------------------------------------------------------
    // Success
    // ---------------------------------------------------------

    return jsonResponse({
      success: true,
      message: "Invitation email sent successfully.",
      email: invitation.email,
      invitationId: invitation.id,
      resendId: resendData?.id ?? null,
    });
  } catch (error) {
    console.error(
      "send-staff-invitation error:",
      error,
    );

    return jsonResponse(
      {
        error:
          error instanceof Error
            ? error.message
            : "Something went wrong.",
      },
      500,
    );
  }
});