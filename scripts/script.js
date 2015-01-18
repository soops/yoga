// Made for YogaScript by Douglas Bumby

var count, yogaCount;
var count = parseInt(localStorage.getItem("yogapantcount"))||0;


yogaCount = function() {
  count = count + 1;
  document.getElementById("yoga-tally").innerHTML = count;
  return 0;
  localStorage.setItem("yogapantcount", count);
};
