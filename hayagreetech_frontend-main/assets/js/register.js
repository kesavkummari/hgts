import API_BASE_URL from "./api_route.js";

document.getElementById("registerForm").addEventListener("submit", async function (event) {
    event.preventDefault(); // Prevent form submission refresh

    // Get form data
    const username = document.getElementById("username").value;
    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;
    const college_name = document.getElementById("college_name").value;
    const year_of_graduation = document.getElementById("year_of_graduation").value;
    const current_year = document.getElementById("current_year").value;
    const roll_number = document.getElementById("roll_number").value;
    const mobile_number = document.getElementById("mobile_number").value;
    const alternative_mobile_number = document.getElementById("alternative_mobile_number").value;
    const location = document.getElementById("location").value;
    const gender = document.getElementById("gender").value;

    // Validation Logic
    const emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
    const mobilePattern = /^[0-9]{10}$/;

    if (!email.match(emailPattern)) {
        alert("Please enter a valid email address.");
        return;
    }
    if (!mobile_number.match(mobilePattern)) {
        alert("Please enter a valid 10-digit mobile number.");
        return;
    }
    if (alternative_mobile_number && !alternative_mobile_number.match(mobilePattern)) {
        alert("Please enter a valid 10-digit alternative mobile number.");
        return;
    }

    try {
        const response = await fetch(`${API_BASE_URL}/create-user/`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                username, 
                email, 
                password, 
                college_name, 
                year_of_graduation, 
                current_year, 
                roll_number, 
                mobile_number, 
                alternative_mobile_number, 
                location, 
                gender
            }),
        });

        const responseData = await response.json();

        if (!response.ok) {
            throw new Error(responseData.detail || "Error creating user");
        } 
        console.log(responseData, "register data");
        localStorage.setItem("email", email);
       
        document.getElementById("message").textContent = responseData.message;

        // Redirect after 1 second
        setTimeout(() => {
            window.location.href = "verify_otp.html";
        }, 1000);

    } catch (error) {
        console.error("Error:", error);
        document.getElementById("message").textContent = "Error submitting form.";
    }
});
