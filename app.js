document.addEventListener('DOMContentLoaded', function () {
  // Get the list of hashes from local storage
  var storedHashes = localStorage.getItem('eventHashes');
  var eventHashes = storedHashes ? JSON.parse(storedHashes) : [];

  // Get all <details> elements on the page
  var detailsElements = document.querySelectorAll('details');

  // Add event listeners to track open/click events
  detailsElements.forEach(function (detailsElement) {
    detailsElement.addEventListener('toggle', function (e) {
      // Add viewed class to the target:
      // TODO: Fix if we use multiple classes.
      e.target.setAttribute('class', 'viewed');
      // Get the data-hash attribute value
      var hash = detailsElement.getAttribute('data-hash');

      // Check if the hash already exists in eventHashes array
      if (!eventHashes.includes(hash)) {
        // Add the hash to the eventHashes array
        eventHashes.push(hash);

        // Limit the eventHashes array to store only the last 100 events
        if (eventHashes.length > 100) {
          eventHashes.shift();
        }

        // Store the updated eventHashes array in local storage
        localStorage.setItem('eventHashes', JSON.stringify(eventHashes));
      }
    });
  });

  // Add "viewed" class to <details> elements with matching hashes
  detailsElements.forEach(function (detailsElement) {
    var hash = detailsElement.getAttribute('data-hash');
    if (eventHashes.includes(hash)) {
      detailsElement.classList.add('viewed');
    }
  });
});
