_ = require 'underscore'
{polarToCartesian} = require './engine'
ptc = polarToCartesian

Draw =

  arc: ({startAngle, endAngle, radius}, thickness = 20) ->

    # console.log "trying to arc", startAngle, endAngle, radius

    {x: innerStartX, y: innerStartY} = ptc radius, startAngle
    {x: innerEndX, y: innerEndY} = ptc radius, endAngle

    {x: outerStartX, y: outerStartY} = ptc radius + thickness, startAngle
    {x: outerEndX, y: outerEndY} = ptc radius + thickness, endAngle

    largeArc = if endAngle - startAngle <= 180 then 0 else 1

    path = [
      "M", innerStartX, innerStartY
      "A", radius, radius, 0, largeArc, 1, innerEndX, innerEndY
      "L", outerEndX, outerEndY
      "A", radius + thickness, radius + thickness, 0, largeArc, 0, outerStartX, outerStartY
      "Z"
    ]

    path.join " "

  arc2: ({unknownStart, unknownEnd, radius}) ->
    @arc {startAngle: unknownStart, endAngle: unknownEnd, radius: radius}


  center: ({startAngle, endAngle, radius}, thickness = 20) ->
    {x, y} = ptc radius + 30, (startAngle + endAngle) / 2

  centerUnknown: ({unknownStart, unknownEnd, radius}, thickness = 20) ->
    {x, y} = ptc radius + 10, (unknownStart + unknownEnd) / 2


  ticks: ({startAngle, endAngle, radius}, thickness = 20) ->

    buildLine = (angle) ->
      {x: startX, y: startY} = ptc radius + 15, angle
      {x: endX, y: endY} = ptc radius + 20, angle
      path = [
        "M", startX, startY
        "L", endX, endY
      ]
      [path.join " "]


    (buildLine angle for angle in [startAngle..endAngle] by 10)


  textDef: ({startAngle, endAngle, radius}, thickness = 20) ->

    # console.log "trying to text", startAngle, endAngle, radius

    radius = radius + 30

    {x: innerStartX, y: innerStartY} = ptc radius, startAngle
    {x: innerEndX, y: innerEndY} = ptc radius, endAngle

    largeArc = if endAngle - startAngle <= 180 then 0 else 1

    path = [
      "M", innerStartX, innerStartY
      "A", radius, radius, 0, largeArc, 1, innerEndX, innerEndY
    ]

    path.join " "


  link: (participants) ->

    pinch = (start, end) ->
      (end - start) * 0.4

    depth = 90

    parts = []

    # Sort the participants so that links between more than two regions
    # don't cross eachother
    participants = _.sortBy participants, "startAngle"

    participants.map (view, i) =>

      {startAngle, endAngle, radius} = view
      centered = @center(view)

      next = if (i + 1) < participants.length then participants[i + 1] else participants[0]

      parts.push [


        if i is 0
          if startAngle is endAngle
            ["M", ptc(radius, startAngle).x, ptc(radius, startAngle).y]
          else
            ["M",
              ptc(radius - depth, startAngle + pinch(startAngle, endAngle)).x
              ptc(radius - depth, startAngle + pinch(startAngle, endAngle)).y]

        if startAngle is endAngle
          ["C",
            ptc(radius, startAngle).x, ptc(radius, startAngle).y
            ptc(radius, startAngle).x, ptc(radius, startAngle).y
            ptc(radius, startAngle).x, ptc(radius, startAngle).y]
        else
          ["C",
            # Start at
            ptc(radius - depth, startAngle + pinch(startAngle, endAngle)).x
            ptc(radius - depth, startAngle + pinch(startAngle, endAngle)).y
            # Curve to
            ptc(radius - depth / 2, startAngle + pinch(startAngle, endAngle)).x
            ptc(radius - depth / 2, startAngle + pinch(startAngle, endAngle)).y
            # End
            ptc(radius, startAngle).x, ptc(radius, startAngle).y]

        ["A", radius, radius, 0,
          if endAngle - startAngle <= 180 then 0 else 1,
          1, ptc(radius, endAngle).x, ptc(radius, endAngle).y]

        if startAngle is endAngle
          ["C",
            ptc(radius, endAngle).x, ptc(radius, endAngle).y
            ptc(radius, endAngle).x, ptc(radius, endAngle).y
            ptc(radius, endAngle).x, ptc(radius, endAngle).y]
        else
          ["C",
            ptc(radius, endAngle).x, ptc(radius, endAngle).y
            ptc(radius - depth / 2, endAngle - pinch(startAngle, endAngle)).x
            ptc(radius - depth / 2, endAngle - pinch(startAngle, endAngle)).y
            ptc(radius - depth, endAngle - pinch(startAngle, endAngle)).x
            ptc(radius - depth, endAngle - pinch(startAngle, endAngle)).y]

        if next
          if next.startAngle is next.endAngle
            ["Q", 0, 0
              ptc(next.radius, next.startAngle).x, ptc(next.radius, next.startAngle).y]
          else
            ["Q", 0, 0
              ptc(next.radius - depth, next.startAngle + pinch(next.startAngle, next.endAngle)).x
              ptc(next.radius - depth, next.startAngle + pinch(next.startAngle, next.endAngle)).y]





        # if startAngle == endAngle
        #   ["Q", 0, 0
        #     ptc(radius, endAngle).x, ptc(radius, endAngle).y]
        # else
        #   ["Q", 0, 0
        #     ptc(radius - 30, endAngle - 10).x, ptc(radius - 30, endAngle - 10).y]
        #
        # ["A", radius, radius, 0,
        #   if endAngle - startAngle <= 180 then 0 else 1,
        #   1, ptc(radius, endAngle).x, ptc(radius, endAngle).y]
      ]


    _.flatten(parts).join " "


module.exports = Draw
