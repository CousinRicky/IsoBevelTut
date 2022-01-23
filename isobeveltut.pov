/* isobeveltut.pov
 * Persistence of Vision Raytracer scene description file
 *
 * Create beveled text using image map-based isosurfaces.
 *
 * Copyright © 2020, 2022 Richard Callwood III.  Some rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Edition  Date         Comments
 * -------  ----         --------
 *          2020-May-16  Created.
 * Initial  2020-Oct-01  Some variable names are changed to match the tutorial.
 * 1.0.1    2022-Jan-23  The 'once' keyword is removed from the image map.
 */
// +W1280 +H720
#version 3.7;

#ifndef (Rad) #declare Rad = yes; #end

#include "shapes.inc"
#include "roundedge.inc"

global_settings
{ assumed_gamma 1 // At this stage, you can use whatever value.
  #if (Rad)
    radiosity
    { count 200
      error_bound 0.5
      pretrace_start 64 / image_width
      pretrace_end 2 / image_width
      recursion_limit 2
    }
  #end
}

light_source
{ vrotate (-1000 * z, <45, 45, 0>), rgb <2.077, 1.979, 1.913>
  parallel point_at 0
}

sky_sphere
{ pigment
  { gradient y color_map
    { [0 rgb <0.242, 0.436, 0.878>]
      [1 rgb <0.0097, 0.073, 0.439>]
    }
  }
}

#declare c_Ambient = rgb <0.114, 0.145, 0.242>;
#declare Diffuse = 0.6;
#default { finish { ambient c_Ambient diffuse Diffuse emission 0 } }

camera
{ location <-20, 8, -50>
  look_at <-2.5, 10, 0>
  right 16/9 * x
  up y
  angle 40
}

plane
{ y, 0
  pigment { rgb 0.35 }
  normal { bumps scale 0.1 }
}

//------------------------------------------------------------------------------

#declare Slab = Round_Box_Union (<-10, 0, 0>, <10, 10, 3>, 0.2)

#declare FONT_SIZE = 8;
#declare TEXT_DEPTH = 0.8;

#macro Make_function (s_Image)
 // interpolate 2 gives the smoothest results.
  #local Pigment = pigment { image_map { exr s_Image interpolate 2 } }
  #local Scaled_pigment = pigment
  { Pigment
    translate -0.5
    scale max_extent (Pigment) / max_extent (Pigment).y * FONT_SIZE + z
  }
  function { pigment { Scaled_pigment } }
#end

#declare fn_Sans_inside = Make_function ("isobeveltut_make1")
#declare fn_Serif_outside = Make_function ("isobeveltut_make2")
#declare fn_Serif_inside = Make_function ("isobeveltut_make3")

//--------------- Rounded edges ------------------
#declare BEVEL_DEPTH = 0.25;
union
{ object { Slab pigment { rgb 1 } }
  union
  { isosurface
    { function
      { sqrt
        ( RE_fn_Blob2 (fn_Sans_inside (x, y, 0).x, 1)
        + RE_fn_Blob2 (TEXT_DEPTH - abs (z), BEVEL_DEPTH)
        ) - 1
      }
      contained_by
      { box { <-7.6, -3.1, -TEXT_DEPTH>, <7.6, 3.1, BEVEL_DEPTH - TEXT_DEPTH> }
      }
      max_gradient 1.2 / BEVEL_DEPTH
    }
    object
    { Center_Object (text { ttf "cyrvetic" "POV" 1, 0 }, x+y)
      scale <FONT_SIZE, FONT_SIZE, BEVEL_DEPTH - TEXT_DEPTH>
    }
    pigment { rgb <1, 0.2, 0.3> }
    translate 5 * y
  }
  rotate -5 * y
  translate <-10.1, 10, 0>
}

//------ Chamfered edges, into the glyphs --------
#declare BEVEL_DEPTH = 0.25;
union
{ object { Slab pigment { rgb 1 } }
  union
  { isosurface
    { function
      { max (1 - z / BEVEL_DEPTH, 0) - fn_Sans_inside (x, y, 0).x
      }
      contained_by { box { <-7.6, -3.1, 0>, <7.6, 3.1, BEVEL_DEPTH> } }
      max_gradient 1.65 / BEVEL_DEPTH
      translate <0, 5, -TEXT_DEPTH>
    }
    object
    { Center_Object (text { ttf "cyrvetic" "POV" 1, 0 }, x+y)
      scale <FONT_SIZE, FONT_SIZE, BEVEL_DEPTH - TEXT_DEPTH>
      translate 5 * y
    }
    pigment { rgb <1, 0.8, 0.2> }
  }
  rotate 5 * y
  translate <10.1, 10, 0>
}

//----- Chamfered edges, outside the glyphs ------
#declare BEVEL_DEPTH = 0.25;
union
{ object { Slab pigment { rgb 1 } }
  isosurface
  { function
    { max (1 - z / BEVEL_DEPTH, 0) - fn_Serif_outside (x, y, 0).x
    }
    contained_by { box { <-8.1, -3.2, 0>, <8.1, 3.2, TEXT_DEPTH> } }
    max_gradient 1.55 / BEVEL_DEPTH
    pigment
    { object
      { Center_Object (text { ttf "timrom" "POV" 1, 0 scale FONT_SIZE }, x+y+z)
        rgb <0.1, 0.2, 0.9>
        rgb <0.6, 0.7, 1>
      }
    }
    translate <0, 5, -TEXT_DEPTH>
  }
  rotate -3 * y
  translate <-10.1, 0, 0>
}

//------------------ Engraved --------------------
#declare BEVEL_DEPTH = 0.5;
#declare wSemi = 7.9;
#declare hSemi = 2.9;
#declare yMid = 5;
union
{ difference
  { object { Slab }
    box
    { <-wSemi, -hSemi, -0.1>, <wSemi, hSemi, BEVEL_DEPTH>
      translate yMid * y
    }
  }
  isosurface
  { function
    { fn_Serif_inside (x, y, 0).x - z / BEVEL_DEPTH
    }
    contained_by { box { <-wSemi, -hSemi, 0>, <wSemi, hSemi, BEVEL_DEPTH> } }
    max_gradient 1.55 / BEVEL_DEPTH
    translate yMid * y
  }
  texture
  { object
    { Center_Object (text { ttf "timrom" "POV" 1, 0 scale FONT_SIZE }, x+y+z)
      texture { pigment { rgb 0.1 } }
      texture
      { pigment { rgb <0.99, 0.76, 0.33> }
        finish
        { diffuse 0.7
          ambient 0.7 * c_Ambient / Diffuse
          brilliance 1.5
          specular albedo 0.2 metallic
          roughness 0.05
        }
        normal { bumps 0.5 scale 0.01 }
      }
    }
    translate yMid * y
  }
  rotate 3 * y
  translate <10.1, 0, 0>
}
