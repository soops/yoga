// Made for YogaScript by Douglas Bumby
var count = parseInt(localStorage.getItem("yogapantcount"))||0;

count = 2;

yogaCount = function() {
  count = count++;
  document.getElementById("yoga-tally").innerHTML = count;
  return 0;
};
