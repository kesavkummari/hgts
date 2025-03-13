import API_BASE_URL from "./api_route.js";

document.addEventListener("DOMContentLoaded", function () {
    document.getElementById("email_loginForm").addEventListener("submit", async function (event) {
        event.preventDefault(); // Prevent form submission refresh

        // Get form data
        const email = document.getElementById("email").value;
        const password = document.getElementById("password").value;

        console.log(email, "Registered Email");
        console.log(password, "registered password")

        try {
            const response = await fetch(`${API_BASE_URL}/email-login-user/`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({ email, password }),
            });
            const responseData = await response.json();
            console.log(responseData,"loginresponsedata"); // For debugging

            if (!response.ok) {
                throw new Error(responseData.detail || "Error Login user");
            }

            document.getElementById("message").textContent = responseData.message;

            // Simulate form submission processing (redirect after 1 second)
            setTimeout(() => {
                window.location.href = "courseviewdashboard.html"; // Redirect to dashboard page after success
            }, 1000); // Redirect after 1 second

        } catch (error) {
            console.error("Error:", error);
            document.getElementById("message").textContent = "Error submitting form.";
        }

        // Reset the form after submission
        this.reset();
    });
});
