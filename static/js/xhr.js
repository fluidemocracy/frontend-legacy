function toggleInterest(issueId) {
  var linkEl = document.getElementById("issue_" + issueId + "_interest_link");
  var iconEl = document.getElementById("issue_" + issueId + "_interest_icon");
  var interested = iconEl.innerHTML == "star_outline";

  if (interested) {
    linkEl.classList.add("mdl-button--accent");
    linkEl.classList.add("mdl-button--feature-on");
    linkEl.classList.remove("mdl-button--feature-off");
    iconEl.innerHTML = "star";
  } else {
    linkEl.classList.remove("mdl-button--accent");
    linkEl.classList.remove("mdl-button--feature-on");
    linkEl.classList.add("mdl-button--feature-off");
    iconEl.innerHTML = "star_outline";
  }
  
  var data = new FormData();
  data.append("issue_id", issueId);
  data.append("interested", interested);

  fetch("/lf/interest/xhr_update", {
      method : "POST",
      body: data
  }).then(
      response => {
        if (response.status != 200) {
          window.alert("Error during update");
        }
      }
  );

}

