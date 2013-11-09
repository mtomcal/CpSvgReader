var svgContainer = d3.select("body").append("svg")
  .attr("width", 140500)
  .attr("height", 2000);

var rectangle_elems = []
chloroplast["elements"].forEach(function(elem) {
    if (elem["rectangle"]) {
      rectangle_elems.push(elem["rectangle"]);
    }
});

var rectangles = svgContainer.selectAll("rect")
  .data(rectangle_elems)
  .enter()
  .append("rect");
  var rectangleAttributes =
                          rectangles
                          .attr("x", function (d) { return d.x; })
                          .attr("y", function (d) { return d.y; })
                          .attr("height", function (d) { return d.height; })
                          .attr("width", function (d) { return d.width; })
                          .style("fill", function(d) { return "red"; });
