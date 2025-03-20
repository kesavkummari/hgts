import API_BASE_URL from "./api_route.js";
document.getElementById("otp_verificationForm").addEventListener("submit", async function (event) {
    event.preventDefault();

    const email = localStorage.getItem("email"); // Retrieve email from localStorage
    console.log(email, "Registered Email");
    const otp = document.getElementById("otp").value;
    const messageDiv = document.getElementById("message");
 
    if (!email) {
        messageDiv.style.color = "red";
        messageDiv.textContent = "❌ No email found. Please register again.";
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/otp/verify-otp`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email, otp }),
        });

        const responseData = await response.json();
        console.log(responseData, "OTP Verification Response");

        if (responseData.status_code==200) {
            messageDiv.style.color = "green";
            messageDiv.textContent = "✅ OTP Verified Successfully! Redirecting...";
            setTimeout(() => {
                window.location.href = "courseviewdashboard.html"; // Redirect to dashboard
            }, 2000);
        } else {
            let errorMessage = "Invalid OTP. Please try again.";
            
            if (responseData.detail) {
                errorMessage = typeof responseData.detail === "string" ? responseData.detail : JSON.stringify(responseData.detail);
            }

            throw new Error(errorMessage);
        }

    } catch (error) {
        console.error("OTP Verification Error:", error);
        messageDiv.style.color = "red";
        messageDiv.textContent = "❌ " + error.message;
    }

    console.log("Sending OTP Verification request:", { email, otp });
});

// Resend OTP Button
document.getElementById("resendOtpBtn").addEventListener("click", async function (event) {
    event.preventDefault();
    const email = localStorage.getItem("email"); 
    const messageDiv = document.getElementById("message");

    if (!email) {
        messageDiv.style.color = "red";
        messageDiv.textContent = "❌ Unable to resend OTP. Please register again.";
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/otp/send-otp`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({email}),  // ✅ Fix: Send email as a plain string
        });

        const responseData = await response.json();
        console.log(responseData, "Resend OTP Response");

        if (responseData.statusCode==200) {
            messageDiv.style.color = "blue";
            messageDiv.textContent = "✅ OTP Resent Successfully! Check your email.";
            // setTimeout(() => {
            //     location.reload();
            // }, 1000);
        } else {
            let errorMessage = "Failed to resend OTP. Try again later.";

            if (responseData.detail) {
                errorMessage = typeof responseData.detail === "string" ? responseData.detail : JSON.stringify(responseData.detail);
            }

            throw new Error(errorMessage);
        }

    } catch (error) {
        console.error("Resend OTP Error:", error);
        messageDiv.style.color = "red";
        messageDiv.textContent = "❌ " + error.message;
    }
});

