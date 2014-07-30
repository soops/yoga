// Made for YogaScript by Douglas Bumby
var count, yogaCount;

count = 2;

yogaCount = function() {
  count = count + 1;
  document.getElementById("yoga-tally").innerHTML = count;
  return 0;
};
