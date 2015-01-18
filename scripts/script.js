// Made for YogaScript by Douglas Bumby
var count, yogaCount;

count = parseInt(localStorage.getItem("yogapants"))||0;
function increment(n) {
  count += n;
  localStorage.setItem("yogapants", octocats);
  document.getElementById("yoga-tally").innerHTML = count;
}
