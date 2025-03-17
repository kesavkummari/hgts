# hgts
To Store Raw Code and Create CI/CD Pipeline




Master username : hgts_usr
Master password : Hgts#2025
Schema Name     : hgts


Lambdas:
    1. hgts-sendemail-otp
    2. hgts-sendemail-notification
    3. hgts-email-login-user
    4. hgts-verify-otp
    5. hgts-send-otp
    6. hgts-create-user
    7. hgts-delete-user

API Gateways:
    API endpoint: https://5qfxnv3qrg.execute-api.ap-south-2.amazonaws.com/default/hgts-sendemail-otp


https://5qfxnv3qrg.execute-api.ap-south-2.amazonaws.com/default/hgts-sendemail-otp

{"email": "arunkumar03jak1@gmail.com", "otp": "234123"}


curl -X POST "https://5qfxnv3qrg.execute-api.ap-south-2.amazonaws.com/default/hgts-sendemail-otp" \
     -H "Content-Type: application/json" \
     -d '{"email": "arunkumar03jak1@gmail.com", "otp": "234123"}'

<script>
  fetch("https://5qfxnv3qrg.execute-api.ap-south-2.amazonaws.com/default/hgts-sendemail-otp", {
      method: "POST",
      headers: {
          "Content-Type": "application/json"
      },
      body: JSON.stringify({
          email: "arunkumar03jak1@gmail.com",
          otp: "234123"
      })
  })
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error(error));
</script>
