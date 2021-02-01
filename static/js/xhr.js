function toggleInterest(issue_id, iconElId) {
  var iconEl = document.getElementById(iconElId);
  var interested = iconEl.innerHTML == "star_outline";
  
  var data = new FormData();
  data.append("issue_id", issue_id);
  data.append("interested", interested);

  fetch("/lf/interest/xhr_update", {
      method : "POST",
      body: data
  }).then(
      response => {
        if (response.status == 200) {
          iconEl.innerHTML = interested ? "star" : "star_outline";
        }
      }
  );

}

