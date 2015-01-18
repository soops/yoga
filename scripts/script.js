// Made for YogaScript by Douglas Bumby
var count;

count = parseInt(localStorage.getItem("yogapants"))||0;
function increment(n) {
  count += n;
  localStorage.setItem("yogapants", count);
  document.getElementById("yoga-tally").innerHTML = count;
}
