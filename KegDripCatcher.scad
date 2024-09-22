/* [Keg Parameters] */
// Keg - Outer Diameter
KegOD = 205;
// Keg - Rim Thickness
KegRimThickness = 25;

/* [Tray Parameters] */
// Tray - Height
TrayHeight = 50;
// Tray - Material Thickness
TrayThickness = 10;

/* [Sponge] */
// Sponge - Width
SpongeWidth = 90;
// Sponge - Depth
SpongeDepth = 65;
// Sponge - Thickness
SpongeThickness = 30;

/* [Grip Parameters] */
// Grip - Height
GripHeight = 20;
// Grip - Material Thickness
GripThickness = 10;

// ###########################################

/* [Hidden] */
// Chamfers
EdgeChamfer = 2;

RenderCludge = 0.01; // Cludge to tidy up rendering interface
Pi = 3.14;
$fn = 60;

// ###########################################

// Calculations
// Keg - Outer R
KegOR = KegOD / 2;
// Keg - Inner R
KegIR = KegOR - KegRimThickness;

// Grip - Height
HookGripHeight = TrayHeight - GripHeight;

// Tray - Outer R
TrayOR = KegOR + SpongeDepth;

// SpongeHolder
SpongeHolderInside = KegOR + TrayThickness;
SpongeHolderOutside = TrayOR - TrayThickness;

// ###########################################

// Outline of drip catcher
module KegDripCatcherBody()
{
/*

 2  |IR-Th..OR +Th|  3
 ┌──────────────────┐
 │                  │
 │   ┌──────────┐   │
 │   │9        8│   │
 │   │ IR    OR │   │GripH
 │   │          │   │
 │   │          │   │4                  5
 └───┘          │   └──────────────────┐
 1    10        │                      │
                │                      │
                │                      │SpongeTh
                │                      │
                └──────────────────────┘
               7                        6

    <-- - / + -->
   
   e.g.
   [0, 0],   // BL
   [0, 10],  // TL
   [10, 10], // TR
   [10, 0]   // BR
   
*/

   polygon
   ([
      // Grip
      [KegIR - GripThickness, (TrayHeight + GripThickness) - EdgeChamfer],
      [(KegIR - GripThickness) + EdgeChamfer, TrayHeight + GripThickness],
      [(KegOR + TrayThickness) - EdgeChamfer, TrayHeight + GripThickness],
      [KegOR + TrayThickness , (TrayHeight + GripThickness) - EdgeChamfer],
      [KegOR + TrayThickness, SpongeThickness],
      // Spongeholder
      [TrayOR - EdgeChamfer, SpongeThickness],
      [TrayOR, SpongeThickness - EdgeChamfer],
      [TrayOR, EdgeChamfer],
      [TrayOR - EdgeChamfer, 0],
      [KegOR + EdgeChamfer, 0],
      [KegOR, EdgeChamfer],
      // Grip + Spongeholder
      [KegOR, TrayHeight - EdgeChamfer],
      [KegOR - EdgeChamfer, TrayHeight],
      [KegIR + EdgeChamfer, TrayHeight],
      [KegIR, TrayHeight - EdgeChamfer],
      [KegIR, HookGripHeight + EdgeChamfer],
      [KegIR - EdgeChamfer, HookGripHeight],
      [(KegIR - GripThickness) + EdgeChamfer, HookGripHeight],
      [KegIR - GripThickness, HookGripHeight + EdgeChamfer]
   ]);
}

// Outline of sponge holder
module SpongeHolder()
{
   polygon
   ([
      [SpongeHolderInside, SpongeThickness + RenderCludge],
      [SpongeHolderOutside, SpongeThickness + RenderCludge],
      [SpongeHolderOutside, TrayThickness],
      [SpongeHolderInside, TrayThickness]
   ]);
}

module CreateText(textString, size, position) {
    translate(position)
        linear_extrude(height = 3)
            text(textString, font = "Leelawadee UI:style=Bold", size = size, valign = "center", halign = "center");
}

module KegDripCatcher()
{
   // Angular step repetition out of 360deg
   AngularRepeat = (360 * SpongeWidth) / (Pi * KegOR * 2);
   // Sponge cut
   SpongeCutAngularRepeat = (360 * TrayThickness) / (Pi * TrayOR * 2);
   
   difference()
   {
      difference()
      {
         // Tray
         rotate_extrude(angle=AngularRepeat) KegDripCatcherBody();

         // SpongeHolder
         rotate([0,0,SpongeCutAngularRepeat])
            rotate_extrude(angle=AngularRepeat - (SpongeCutAngularRepeat * 2))
               SpongeHolder();

      }
      
      #CreateText("ZETA", size = 9, position = [KegOR - (KegRimThickness / 2), 10, (TrayHeight + GripThickness) - 3 + RenderCludge]);
   }
}

// ###########################################

KegDripCatcher();