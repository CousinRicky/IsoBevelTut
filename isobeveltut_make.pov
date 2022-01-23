/* isobeveltut_make.pov
 * Persistence of Vision Raytracer scene description file
 *
 * Creates image maps of text suitable for beveling.
 *
 * Copyright © 2020 Richard Callwood III.  Some rights reserved.
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
 *          2020-May-15  Created.
 *          2020-Oct-05  A progress indicator is written to the debug stream.
 * Initial  2020-Oct-14  The technique is made to work with odd image
 *          dimensions.
 * 1.0.1    2022-Jan-23  No change.
 */
// +KFF3 +FE +W1200 +H500 -A
#version 3.7;

#include "shapes.inc"

global_settings { assumed_gamma 1 } // Important!
#default { finish { ambient 0 diffuse 0 emission 1 } } // Important!

camera
{ orthographic
  location -z
  right image_width * x
  up image_height * y
}

#switch (frame_number)
  #case (1)
    #declare S_FONT = "cyrvetic"
    #declare Inside = yes;
    #declare Bevel = 0.03;
    #break
  #case (2)
    #declare S_FONT = "timrom"
    #declare Inside = no;
    #declare Bevel = 0.03;
    #break
  #case (3)
    #declare S_FONT = "timrom"
    #declare Inside = yes;
    #declare Bevel = 0.06;
    #break
  #else
    #error "Please render with +KFF3."
#end

#declare Monogram = Center_Object
( text
  { ttf S_FONT "POV" 1, 0
    scale <image_height, image_height, 1>
  },
  x+y+z
)

#declare Pixel = box { -0.5, 0.5 }
#declare ScaledBevel = image_height * Bevel;

// Correct for odd image dimensions--to make sure sampling is of the pixel
// centers and not between pixels:
#declare xEnd = mod (image_width, 2);
#declare yEnd = mod (image_height, 2);
#declare v_Center = <1 - xEnd, 1 - yEnd, 0> / 2;

// Scan the text:
#if (Inside)
  #declare Y1 = floor (min_extent (Monogram).y);
  #declare Y2 = ceil (max_extent (Monogram).y) + yEnd;
  #declare X1 = floor (min_extent (Monogram).x);
  #declare X2 = ceil (max_extent (Monogram).x) + xEnd;
  #for (Y, Y1, Y2 - 1)
    #if (mod (Y - Y1 + 1, 10) = 0)
      #debug concat
      ( "Scanning pixel row ", str (Y - Y1 + 1, 0, 0),
        " of ", str (Y2 - Y1, 0, 0), ".\n"
      )
    #end
    #for (X, X1, X2 - 1)
      #declare v_MidPt = <X, Y, 0> + v_Center;
      #if (inside (Monogram, v_MidPt))
        #declare Dist = image_width; // Initialize with a large value.
        #for (Theta, 0, 359)
          #declare v_Hit = trace (Monogram, v_MidPt, vrotate (x, Theta * z));
          #declare Dist = min (Dist, vlength (v_Hit - v_MidPt));
        #end
        object
        { Pixel
          translate v_MidPt
          pigment { rgb min (Dist / ScaledBevel, 1) }
        }
      #end
    #end
  #end
#else
  #declare Normal = <0,0,0>;
  #declare Y1 = floor (min_extent (Monogram).y - ScaledBevel);
  #declare Y2 = ceil (max_extent (Monogram).y + ScaledBevel) + yEnd;
  #declare X1 = floor (min_extent (Monogram).x - ScaledBevel);
  #declare X2 = ceil (max_extent (Monogram).x + ScaledBevel) + xEnd;
  #for (Y, Y1, Y2 - 1)
    #if (mod (Y - Y1 + 1, 10) = 0)
      #debug concat
      ( "Scanning pixel row ", str (Y - Y1 + 1, 0, 0),
        " of ", str (Y2 - Y1, 0, 0), ".\n"
      )
    #end
    #for (X, X1, X2 - 1)
      #declare v_MidPt = <X, Y, 0> + v_Center;
      object
      { Pixel
        translate v_MidPt
        #if (inside (Monogram, v_MidPt))
          pigment { rgb 1 }
        #else
          #declare Dist = image_width; // Initialize with a large value.
          #for (Theta, 0, 359)
            #declare v_Hit =
              trace (Monogram, v_MidPt, vrotate (x, Theta * z), Normal);
            #if (vlength (Normal))
              #declare Dist = min (Dist, vlength (v_Hit - v_MidPt));
            #end
          #end
          pigment { rgb max (1 - Dist / ScaledBevel, 0) }
        #end
      }
    #end
  #end
#end
