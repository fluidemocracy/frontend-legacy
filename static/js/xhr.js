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

  fetch(baseURL + "interest/xhr_update", {
    method: "POST",
    body: data
  }).then(response => {
    if (response.status != 200) {
      window.alert("Error during update");
    }
  });

}

function rateSuggestion(id, degree, fulfilled) {
  document.getElementById('rating_suggestion_id').value = id;
  document.getElementById('rating_degree' + degree).MaterialRadio.check();
  if (fulfilled) {
    document.getElementById('rating_fulfilled').MaterialRadio.check();
  } else if (fulfilled == false) {
    document.getElementById('rating_notfulfilled').MaterialRadio.check();    
  } else {
    document.getElementById('rating_fulfilled').MaterialRadio.uncheck();    
    document.getElementById('rating_notfulfilled').MaterialRadio.uncheck();    
  }
//  document.getElementById('rating_dialog').showModal();
  document.getElementById('rating_dialog').classList.remove("hidden");

}

function updateOpinion() {
  var suggestionId = document.getElementById("rating_suggestion_id").value;
  
  var degree = 0;
  if (document.getElementById("rating_degree-2").children[0].checked)
    degree = -2;
  else if (document.getElementById("rating_degree-1").children[0].checked)
    degree = -1;
  else if (document.getElementById("rating_degree1").children[0].checked)
    degree = 1;
  else if (document.getElementById("rating_degree2").children[0].checked)
    degree = 2;
  var fulfilled = false;
  if (document.getElementById("rating_fulfilled").children[0].checked)
    fulfilled = true;
  if (degree == 0)
    fulfilled = null;
  var data = new FormData();
  data.append("suggestion_id", suggestionId);
  data.append("degree", degree);
  data.append("fulfilled", fulfilled);

  var degreeText = rateSuggestionDegreeTexts[degree];
  var fulfilledText = fulfilled ? rateSuggestionFulfilledText : rateSuggestionNotFulfilledText;
  var textTemplate;
  var icon;
  var iconColor;
  if (
    (degree > 0 && ! fulfilled)
    || (degree < 0 && fulfilled) 
  ) {
    icon = "warning";
    if (degree == 2 || degree == -2) { 
      iconColor = "red";
    }
    textTemplate = rateSuggestionButText;
  } else {
    textTemplate = rateSuggestionAndText;
    icon = "done";
  }
  textTemplate = textTemplate.replace("#{opinion}", degreeText);
  textTemplate = textTemplate.replace("#{implemented}", fulfilledText);
  var text = textTemplate;
  if (degree == 0) {
    text = "";
    icon = "blank";
  }
  document.getElementById("s" + suggestionId + "_rating_text").innerHTML = text;
  document.getElementById("s" + suggestionId + "_rating_icon").innerHTML = icon;
  if (iconColor == "red") {
    document.getElementById("s" + suggestionId + "_rating_icon").classList.add("icon-red");
  } else {
    document.getElementById("s" + suggestionId + "_rating_icon").classList.remove("icon-red");
  }  
  if (degree == 0) {
    document.getElementById("s" + suggestionId + "_rate_button").innerHTML = rateSuggestionRateText;
  } else {
    document.getElementById("s" + suggestionId + "_rate_button").innerHTML = rateSuggestionUpdateRatingText;
  }
  document.getElementById("s" + suggestionId + "_rate_button").setAttribute("onclick", "rateSuggestion(" + suggestionId + ", " + degree + ", " + fulfilled + ");return false;")
//  document.getElementById('rating_dialog').close();
  document.getElementById('rating_dialog').classList.add("hidden");

  fetch(baseURL + "opinion/xhr_update", {
    method: "POST",
    body: data
  }).then(response => {
    if (response.status != 200) {
      window.alert("Error during update");
    }
  });

}
