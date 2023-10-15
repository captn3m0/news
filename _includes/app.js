// Note: Use ES5 only

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

  // Set highlight words
  if(hw = document.getElementById('highlight-words')) {
    hw.value = (JSON.parse(localStorage.getItem("highlightWords"))||[]).join(",");

    // Dealing with Textarea Height
    function calcHeight(value) {
      let numberOfLineBreaks = (value.match(/\n/g) || []).length;
      let newHeight = Math.max(50,50+numberOfLineBreaks * 20);
      return newHeight;
    }

    hw.style.height = calcHeight(hw.value) + "px";
    hw.addEventListener("keyup", () => {
      hw.style.height = calcHeight(hw.value) + "px";
    });

  }

  // Save settings
  if(document.getElementById('btn-settings-save')) {
    document.getElementById('btn-settings-save').addEventListener('click', function (e) {
      val = document.getElementById('highlight-words').value.split(",").map(function(x){return x.trim()});
      localStorage.setItem('highlightWords', JSON.stringify(val));
      // Flash save
      document.getElementById('btn-settings-save').value='Saved';
      setTimeout(function(){document.getElementById('btn-settings-save').value='Save';}, 500);
      // Don't refresh page
      return false;
    });
  }

  // Enable highlighting
  if(words = localStorage.getItem('highlightWords')) {
    var scriptTag = document.createElement('script');
    scriptTag.setAttribute('src','/assets/mark.min.js');
    scriptTag.async=scriptTag.defer = true;
    document.body.appendChild(scriptTag);
    scriptTag.onload = function() {
      var markInstance = new Mark(document.querySelector("main"));
      markInstance.mark(JSON.parse(words), {});
    }
  }

  // Reset read articles
  if(reset = document.getElementById('btn-settings-reset')){
    reset.addEventListener('click', function (e) {
      localStorage.setItem('eventHashes', JSON.stringify([]));
      // Flash reset
      e.target.value='All articles marked unread';
      e.target.disabled=true;
      setTimeout(function(){e.target.value='Reset';e.target.disabled=false;}, 500);
      // Don't refresh page
      return false;
    });
  }

  // Set checkboxes from local storage in settings.html
  let x = localStorage.getItem('hiddenTopics');
  let hiddenTopics = x ? JSON.parse(x) : [];

  // Set hidden count in the button and show it.
  if (hiddenTopics && document.getElementById("hidden-notifier")) {
    document.getElementById("hidden-count").innerText = hiddenTopics.length;
    document.getElementById("hidden-notifier").style.display = "inline";
  }
  for (let topic of hiddenTopics) {
    let topicCheckbox = document.querySelector(`#checkbox-hide-${topic}`);
    if (topicCheckbox) {
      topicCheckbox.checked = true;
    }
  }

  // Show hidden elements on clicking the button
  if (document.getElementById("hidden-notifier")) {
    document.getElementById("hidden-notifier").addEventListener('click', function (e) {
      document.getElementById('hidden-style').remove();
      document.getElementById("hidden-notifier").style.display = "none";
    });
  }

  // On clicking checkbox, add it to localstorage
  let checkboxes = document.querySelectorAll('.checkbox-hide');
  for (let checkbox of checkboxes) {
    checkbox.addEventListener('click', function (e) {
      let topic = e.target.value;
      let x = JSON.parse(localStorage.getItem('hiddenTopics'));
      hiddenTopics = new Set(x)
      
      if (e.target.checked) {
        hiddenTopics.add(topic);
      } else {
        hiddenTopics.delete(topic);
      }
      localStorage.setItem('hiddenTopics', JSON.stringify(Array.from(hiddenTopics)));
    });
  }

});
