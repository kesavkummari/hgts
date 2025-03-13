// document.getElementById('pay-button').onclick = function() {
//     var options = {
//         "key": "your_razorpay_key", 
//         "amount": "50000", 
//         "currency": "INR",
//         "name": "Hayagreeva Tech Solutions",
//         "description": "Course Enrollment",
//         "image": "logo.png",
//         "handler": function (response) {
//             alert('Payment successful! Payment ID: ' + response.razorpay_payment_id);
//         },
//         "theme": {
//             "color": "#3399cc"
//         }
//     };
//     var rzp = new Razorpay(options);
//     rzp.open();
// };

document.querySelectorAll('.download-link').forEach(link => {
    link.addEventListener('click', function(event) {
        event.preventDefault();
        const courseName = this.getAttribute('data-course-name');
        alert(`You clicked on ${courseName} Detailed Content`);
    });
});