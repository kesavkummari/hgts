document.addEventListener("DOMContentLoaded", function () {
    // Add event listener to the enroll button
    document.querySelector(".enroll-button").addEventListener("click", function (event) {
        event.preventDefault(); // Prevent default behavior (if any)

        // Redirect to payment page
        window.location.href = "paymentgateway.html";
    });
});