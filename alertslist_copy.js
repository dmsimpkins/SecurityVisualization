// Generated by CoffeeScript 1.3.3
(function() {
  var agewidth, colorMap, count, draw, first, h, ipmargin, list, margin, slidermargin, sliderwidth, w;

  h = 50;

  w = 400;

  margin = 15;

  agewidth = 50;

  sliderwidth = 5;

  slidermargin = 5;

  ipmargin = 7;

  first = 0;

  count = 20;

  colorMap = ['#2e99c4', '#9fc2e2', '#fdf9cd', '#fc93ba', '#d62028'];

  window.scrollUp = function() {
    first -= count;
    if (first < 0) {
      first = 0;
    }
    if (first === 0) {
      $('#pageup').attr('disabled', 'disabled');
    }
    return draw();
  };

  window.scrollDown = function() {
    first += count;
    $('#pageup').removeAttr('disabled');
    return draw();
  };

  list = d3.select('svg').attr('width', w).attr('height', h * count);

  draw = function() {
    d3.json('query_alerts.php?first=' + first + '&count=' + count, function(data) {
      var a, b, d, s;
      data = data.items;
      b = list.selectAll('.background').data(data, function(d) {
        return d.alert_id;
      });
      b.enter().append('rect').attr('class', 'background').attr('x', 0).attr('y', function(d, i) {
        return i * h;
      }).attr('width', w).attr('height', h);
      b.exit().remove();
      b.on('click', function(d) {
        return window.location = 'alertdetail.php?alert_id=' + d.alert_id;
      });
      a = list.selectAll('.ageleft').data(data, function(d) {
        return d.alert_id;
      });
      a.enter().append('rect').attr('class', 'ageleft').attr('x', margin).attr('y', function(d, i) {
        return i * h + margin;
      }).attr('width', function(d) {
        return d.age * agewidth;
      }).attr('height', h - margin * 2);
      a.exit().remove();
      a = list.selectAll('.ageright').data(data, function(d) {
        return d.alert_id;
      });
      a.enter().append('rect').attr('class', 'ageright').attr('x', function(d) {
        return margin + d.age * agewidth;
      }).attr('y', function(d, i) {
        return i * h + margin;
      }).attr('width', function(d) {
        return (1 - d.age) * agewidth;
      }).attr('height', h - margin * 2).style('fill', function(d) {
        return d3.interpolateRgb('black', '#eee')(d.age).toString();
      });
      a.exit().remove();
      s = list.selectAll('.slider').data(data, function(d) {
        return d.alert_id;
      });
      s.enter().append('rect').attr('class', 'slider').attr('x', function(d) {
        return margin + d.age * agewidth - sliderwidth / 2.0;
      }).attr('y', function(d, i) {
        return i * h + margin - slidermargin;
      }).attr('width', sliderwidth).attr('height', h - margin * 2 + slidermargin * 2);
      s.exit().remove();
      $('.slider').tipsy({
        gravity: 'n',
        title: function() {
          var d;
          d = this.__data__;
          return d.date_time;
        }
      });
      s = list.selectAll('.source').data(data, function(d) {
        return d.alert_id;
      });
      s.enter().append('rect').attr('class', 'source').attr('x', margin * 3 + agewidth).attr('y', function(d, i) {
        return h * i + margin;
      }).attr('width', h - margin * 2).attr('height', h - margin * 2).style('fill', function(d) {
        return colorMap[d.src_ip_type];
      });
      s.exit().remove();
      s.on('mouseover', function(d) {
        return window.highlightSource(d.src_ip);
      });
      s.on('mouseout', function() {
        return $('.source').css('stroke', 'black').css('stroke-width', 1);
      });
      $('.source').tipsy({
        gravity: 'n',
        title: function() {
          var d, str;
          d = this.__data__;
          str = d.src_ip;
          if (d.src_port !== 0) {
            str += ':' + d.src_port;
          }
          return str += ' (' + d.src_ip_class + ')';
        }
      });
      d = list.selectAll('.destination').data(data, function(d) {
        return d.alert_id;
      });
      d.enter().append('rect').attr('class', 'destination').attr('x', margin + agewidth + h + ipmargin).attr('y', function(d, i) {
        return h * i + margin;
      }).attr('width', h - margin * 2).attr('height', h - margin * 2).style('fill', function(d) {
        return colorMap[d.dst_ip_type];
      });
      d.exit().remove();
      d.on('mouseover', function(d) {
        return window.highlightDestination(d.dst_ip);
      });
      d.on('mouseout', function() {
        return $('.destination').css('stroke', 'black').css('stroke-width', 1);
      });
      $('.destination').tipsy({
        gravity: 'n',
        title: function() {
          var str;
          d = this.__data__;
          str = d.dst_ip;
          if (d.dst_port !== 0) {
            str += ':' + d.dst_port;
          }
          return str += ' (' + d.dst_ip_class + ')';
        }
      });
      d = list.selectAll('.details').data(data, function(d) {
        return d.alert_id;
      });
      d.enter().append('text').attr('class', 'details').attr('x', margin + agewidth + h * 2 + ipmargin).attr('y', function(d, i) {
        return h * (i + 0.5) + 8;
      }).attr('width', 300).attr('dy', -3).text(function(d) {
        return d.details;
      });
      return d.exit().remove();
    });
    return d3.json("query_histogram", function(json) {
      var barCount, barHeight, barLength, data, totalHeight;
      data = json.items;
      barCount = data.length;
      totalHeight = height * count;
      barHeight = totalHeight / barCount;
      barLength = 200;
      return list.selectAll('');
    });
  };

  window.highlightSource = function(ip) {
    $('.source').css('stroke', function() {
      var d;
      d = this.__data__;
      if (d.src_ip === ip) {
        return 'red';
      } else {
        return 'black';
      }
    });
    return $('.source').css('stroke-width', function() {
      var d;
      d = this.__data__;
      if (d.src_ip === ip) {
        return 3;
      } else {
        return 1;
      }
    });
  };

  window.highlightDestination = function(ip) {
    $('.destination').css('stroke', function() {
      var d;
      d = this.__data__;
      if (d.dst_ip === ip) {
        return 'red';
      } else {
        return 'black';
      }
    });
    return $('.destination').css('stroke-width', function() {
      var d;
      d = this.__data__;
      if (d.dst_ip === ip) {
        return 3;
      } else {
        return 1;
      }
    });
  };

  draw();

}).call(this);
