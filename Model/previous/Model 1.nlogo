globals
[ number_of_agents ]


patches-own
[
  red-media ;; conservative media exposure
  blue-media ;; liberal media exposure
]

turtles-own
[
  attitudes   ;; my attitudes (0 - oppose or 1 - support). We defined the "supporting issue" means he or she is a Democrat.
  prior-attitudes  ;; attitudes at prior waves
  tally  ;; sum of one's own attitudes, total, and mass media exposure
  total_social  ;; sum of attitudes around me from social networks
  total_media   ;; sum of media influence
  my-connected-neighbors  ;; other actors in their networks
  disagree ;; degree of disagreement on his or her social networks

]

to setup
  clear-all
  clear-all-plots

  resize-world 0 (world-size-x - 1) 0 (world-size-y - 1) ;; defining the size of the society (number of patches
  set number_of_agents (world-size-x * world-size-y)     ;; one agent per patch
  set-patch-size 360 / world-size-y                      ;; setting patch size for good looking

  setup-turtles                                          ;; creating the agents, locating them and setting their attitudes values randomly

  ask turtles
    [ set attitudes random 2 ; randomly return 0 or 1
      recolor-turtles
      recolor-patch ]


  reset-ticks
end

;; Turtles settings
to setup-turtles
  set-default-shape turtles "default"
  create-turtles number_of_agents [
    set size 0.8
    while [any? other turtles-here] [ move-to one-of patches ] ;; setting agent location. Only one agent at each patch
  ]

end


;; this is master behavioral schedule of an agent (= patch)
to go

  if count turtles with [ attitudes = 1 ] = 0 or count turtles with [ attitudes = 0 ] = 0 [stop]
  if ticks >= 500
  [stop]

  ask turtles [ watch-media ]
  ask turtles [ select-discussion-partners ]
  ask turtles [ discuss-politics ]
  ask turtles [ update-opinion ]
  ask turtles [ recolor-turtles ]
  ask turtles [ recolor-patch ]

  tick
  ask patches [set blue-media 0]
  ask patches [set red-media 0]
end


to watch-media  ;; need to work on this model. how "selective" exposure map into this submodel?

  ifelse attitudes = 0 ;; if republican or not
  [ set red-media 1] ;; republicans watch red-media
  [ set blue-media 1] ;; democrats watch blue-media

  if exposure-to-counter-media > 0
  [ if random-float 1 < exposure-to-counter-media  ;; if random num is less than counter-explosure threshold,
    [ ifelse attitudes = 0
     [ set blue-media blue-media + 1 ]  ;; for republicans increase blue media exposure
     [ set red-media red-media + 1 ]    ;; for democrats increase red media exposure
  ]
  ]

  ifelse blue-media - red-media > 0
  [ set total_media 1 ]  ;; support minus oppose. If grater than zero, means media favors supporting issue position
  [ ifelse blue-media = red-media
    [ set total_media 0.5 ]
    [ set total_media 0 ]
  ]

end



  ;; this part describes selection rules for potential discussants, which is based on homophily in their attitudes

to select-discussion-partners

ifelse discussant-select-base-on-homophily = true

[  repeat count neighbors
       [ let neighbor one-of turtles-on neighbors ;; define one of turtle as "neighbor"

         ;; create link with neighbor who has same attitudes when a random number is greater than min homophily threshold
         ifelse (random-float 1 < propensity-for-homophily)
         [ if [attitudes] of neighbor = [attitudes] of self [create-link-with neighbor]]
         [ if [attitudes] of neighbor != [attitudes] of self [create-link-with neighbor]]

       ] ; end repeat

  set my-connected-neighbors link-neighbors
  ask links [die] ]

[ set my-connected-neighbors turtles-on neighbors ]


end

to discuss-politics

if any? my-connected-neighbors
[
   set total_social mean [attitudes] of my-connected-neighbors ; define "total" as the mean opinion distribution of one's network

   ifelse attitudes = 1 ;; if an agent supports the position
      [ set disagree (count my-connected-neighbors with [ attitudes = 0 ]) / count (my-connected-neighbors) ]
      [ set disagree (count my-connected-neighbors with [ attitudes = 1 ]) / count (my-connected-neighbors) ]
]

end




to update-opinion  ;; need to work on this logic !!!!!!!!!!!!!!

if opinion-model? = "weighted-mean-average"

[  set prior-attitudes attitudes
  let SINP social-influence-parameter
  let MINP media-influence-parameter
  let STBP stability-parameter
  let random-variation-prior-attitudes random-float (1 - STBP)

  ifelse prior-attitudes = 0
  [ set prior-attitudes prior-attitudes + random-variation-prior-attitudes  ]
  [ set prior-attitudes prior-attitudes - random-variation-prior-attitudes  ]

  ifelse any? my-connected-neighbors
  [ set tally (prior-attitudes + SINP * total_social + MINP * total_media) / 3 ]

  ;; [ set tally (prior-attitudes + total_social + total_media * disagree) / 3 ]




  [ set tally (prior-attitudes + MINP * total_media) / 2 ]

      if tally > 0.5 [ set attitudes 1 ]  ; if mean is greater than 0.5, support the issue
      if tally < 0.5 [ set attitudes 0 ]  ; if mean is less than 0.5, oppose the issue
      if tally = 0.5
        [ if change-attitudes-if-tied?
          [ set attitudes (1 - attitudes) ] ] ]

if opinion-model? = "current-social-only"

[ ifelse any? my-connected-neighbors
  [ if total_social > 0.5 [ set attitudes 1 ]  ; if mean is greater than 0.5, support the issue
      if total_social < 0.5 [ set attitudes 0 ]  ; if mean is less than 0.5, oppose the issue
      if total_social = 0.5
        [ if change-attitudes-if-tied?
          [ set attitudes (1 - attitudes) ] ] ]
  [ set attitudes attitudes ]

]

if opinion-model? = "social-and-media"

[ set prior-attitudes attitudes

  ifelse any? my-connected-neighbors
  [ set tally (total_social + total_media) / 2 ]
  [ set tally (total_media) ]

   if tally > 0.5 [ set attitudes 1 ]  ; if mean is greater than 0.5, support the issue
      if tally < 0.5 [ set attitudes 0 ]  ; if mean is less than 0.5, oppose the issue
      if tally = 0.5
        [ if change-attitudes-if-tied?
          [ set attitudes (1 - attitudes) ] ] ]


end


to recolor-turtles

  ifelse attitudes = 0
    [ set color 14 ] ;; if republican (=0), set red
    [ set color 86 ] ;; if Democrats (=1), set blue

end


to recolor-patch  ;; patch procedure
  ifelse attitudes = 0
    [ set pcolor orange ] ;; if Repulican ("do not support"), color as orange
    [ set pcolor sky ] ;; if Democrats ("support"), color as sky
end


; Copyright 1998 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
230
10
600
401
-1
-1
7.2
1
10
1
1
1
0
1
1
1
0
49
0
49
1
1
1
ticks
30.0

BUTTON
20
140
115
195
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
18
210
73
243
Run
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
708
13
796
58
Democrats
count turtles with\n  [ color = 86 ]
0
1
11

MONITOR
613
13
701
58
Republicans
count turtles with\n  [ color = 14 ]
0
1
11

SWITCH
827
103
1012
136
change-attitudes-if-tied?
change-attitudes-if-tied?
1
1
-1000

SLIDER
659
255
868
288
exposure-to-counter-media
exposure-to-counter-media
0
1
0.2
0.05
1
NIL
HORIZONTAL

PLOT
626
298
926
448
Exposure to countter-attr media
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -13345367 true "" "if any? turtles with [ attitudes = 0 ] [plot mean [ blue-media ] of turtles with [ attitudes = 0 ]]"
"pen-1" 1.0 0 -2674135 true "" "if any? turtles with [ attitudes = 1 ] [plot mean [ red-media ] of turtles with [ attitudes = 1 ]]"

INPUTBOX
21
68
93
128
world-size-x
50
1
0
Number

INPUTBOX
100
69
170
129
world-size-y
50
1
0
Number

BUTTON
82
210
165
243
Run once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
996
359
1183
392
propensity-for-homophily
propensity-for-homophily
0
1
0.5
0.1
1
NIL
HORIZONTAL

MONITOR
996
304
1166
349
mean N of discussants of agents
mean [ count my-connected-neighbors ] of turtles
17
1
11

MONITOR
829
147
964
192
mean "on-line tally"
mean [tally] of turtles
17
1
11

SLIDER
1052
137
1246
170
social-influence-parameter
social-influence-parameter
0
1
1
0.05
1
NIL
HORIZONTAL

SLIDER
1052
58
1250
91
media-influence-parameter
media-influence-parameter
0
1
1
0.05
1
NIL
HORIZONTAL

PLOT
996
404
1196
554
overall network homophily
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [ 1 - disagree ] of turtles"

MONITOR
659
518
921
563
mean valence of media exposure, Democrats
mean [ total_media ] of turtles with [attitudes = 1]
17
1
11

CHOOSER
997
251
1225
296
discussant-select-base-on-homophily
discussant-select-base-on-homophily
true false
1

CHOOSER
828
50
1010
95
opinion-model?
opinion-model?
"current-social-only" "social-and-media" "weighted-mean-average"
2

MONITOR
661
467
904
512
mean valence of media exposure
mean [ total_media ] of turtles
17
1
11

SLIDER
1052
98
1224
131
stability-parameter
stability-parameter
0
1
0.7
0.05
1
NIL
HORIZONTAL

MONITOR
996
563
1316
608
disagreement ratio among those with at least one disagreement
mean [ disagree ] of turtles with [ disagree > 0 ]
17
1
11

MONITOR
660
565
920
610
mean valence of media exposure, Republicans
mean [ total_media ] of turtles with [attitudes = 0]
17
1
11

TEXTBOX
730
228
836
251
Media Exposure\n
14
0.0
1

TEXTBOX
1043
222
1193
240
Political discussion
14
0.0
1

TEXTBOX
862
16
1012
34
Opinion dynamics
14
0.0
1

TEXTBOX
87
31
237
49
Setup
14
0.0
1

@#$#@#$#@
## WHAT IS IT?

This model is a simple cellular automaton that simulates voting distribution by having each patch take a "vote" of its eight surrounding neighbors, then perhaps change its own vote according to the outcome.

## HOW TO USE IT

Click the SETUP button to create an approximately equal but random distribution of blue and green patches.  Click GO to run the simulation.

When both switches are off, the central patch changes its color to match the majority vote, but if there is a 4-4 tie, then it does not change.

If the CHANGE-VOTE-IF-TIED? switch is on, then in the case of a tie, the central patch will always change its vote.

If the AWARD-CLOSE-CALLS-TO-LOSER? switch is on, then if the result is 5-3, the central patch votes with the losing side instead of the winning side.

## THINGS TO NOTICE

Watch how any setup quickly settles to a static state when both switches are off.

Watch what happens when only the CHANGE-VOTE-IF-TIED? switch is on.  How is the result different?

Watch what happens when only the AWARD-CLOSE-CALLS-TO-LOSER? switch is on.  How is the result different?

What happens when both switches are on?

## EXTENDING THE MODEL

Try other voting rules.

Start with a nonrandom green-and-blue pattern. For example, one could make half of the world blue and half green.

Can you enhance the model to incorporate multiple colors and multiple votes?  One might interpret shades of color to represent the degree of a patch's opinion about an issue: strongly against, against, neutral, etc.  Each patch could have more than two choices and weighted votes: blue patches' vote could count twice, etc.

## RELATED MODELS

Ising (a physics model, but the rules are very similar)

## CREDITS AND REFERENCES

This model is described in Rudy Rucker's "Artificial Life Lab", published in 1993 by Waite Group Press.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1998).  NetLogo Voting model.  http://ccl.northwestern.edu/netlogo/models/Voting.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1998 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.

<!-- 1998 2001 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
