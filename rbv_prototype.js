var linearScale = d3.scale.linear()
.domain([0,100])
.range([0,10]);
var scale = d3.scale.linear()
    .domain([0,1])
    .range([150, 16]);


var svgContainer = d3.select("body").append("svg")
  .attr("width", window.innerWidth)
  .attr("height", window.innerHeight);

var rectangle_elems = []
var line_elems = []
var text_elems = []
chloroplast["elements"].forEach(function(elem) {
    if (elem["rectangle"]) {
      rectangle_elems.push(elem["rectangle"]);
    }
    if (elem["line"]) {
      line_elems.push(elem["line"]);
    }
    if (elem["text"]) {
      text_elems.push(elem["text"]);
    }
});

var lines = svgContainer.selectAll("line")
.data(line_elems)
.enter()
.append("line")

var lineAttributes = lines 
.attr("x1", function (d) { return linearScale(d.x1); })
.attr("y1", function (d) { return linearScale(d.y1); })
.attr("x2", function (d) { return linearScale(d.x2); })
.attr("y2", function (d) { return linearScale(d.y2); })
.style("stroke", function(d) { return "black"; });

var rectangles = svgContainer.selectAll("rect")
.data(rectangle_elems)
.enter()
.append("rect");

var rectangleAttributes = rectangles
.attr("x", function (d) { return linearScale(d.x); })
.attr("y", function (d) { return linearScale(d.y); })
.attr("height", function (d) { return linearScale(d.height); })
.attr("width", function (d) { return linearScale(d.width); })
.style("fill", function(d) { return "red"; })


var labels = svgContainer.selectAll("text")
.data(text_elems)
.enter()
.append("text")

var labelAttributes = labels 
.attr("x", function (d) { return linearScale(d.x); })
.attr("y", function (d) { return linearScale(d.y); })
.style("fill", function(d) { return "black"; })
.text(function (d) { return d.seq; });

function zoomed() {
  svgContainer.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")"); 
  labelAttributes
  .attr("y", function (d) { return linearScale(d.y) - (d3.event.scale * 20 * Math.PI); })
  .style("font-size", function () {
    var size = d3.select(this).style("font-size").replace(/px/, "");
    var increment = scale(d3.event.scale);
    if (increment <= 16) {
      return "16px";
    } 
    //if (increment >= 48) {
    //  return "48px";
    //}

    return increment + "px";
  })
  .attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")"); 
  rectangleAttributes.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")"); 
  lineAttributes.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")"); 
}


var zoom = d3.behavior.zoom()
.on("zoom", zoomed);

var body = d3.select("svg").call(zoom);




