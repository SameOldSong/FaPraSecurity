console.log('Client-side code running');

const button = document.getElementById('showButton');
button.addEventListener('click', function(e) {
  console.log('button was clicked');

  fetch('/clicked', {method: 'GET'})
    .then(function(response) {
      if(response.ok) return response.json();
      throw new Error('Request failed.');
    })
    .then(function(data) {
      document.getElementById('result').innerHTML = `${data[0].quote}`;
    })
    .catch(function(error) {
      console.log(error);
    });
});
