// Made for YogaScript by Douglas Bumby
var count = parseInt(localStorage.getItem("yogapantcount"))||0;
var yogaCount;


count = 2;

yogaCount = function() {
  count = count++;
  document.getElementById("yoga-tally").innerHTML = count;
  localStorage.setItem("yogapantcount", count);
  return 0;
};
