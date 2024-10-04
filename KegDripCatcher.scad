/* [Model to Generate] */
// Select which model to generate
Model="DT"; // [DT:Drip Catcher, CO:CO2 Holder]

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

/* [CO2] */
// CO2 - Diameter
GasDiameter = 65;

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
$fn = 360;

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

/*

 2  |IR-Th..OR+Th|  3
 ┌──────────────────┐
 │                  │
 │   ┌──────────┐   │
 │   │9        8│   │
 │   │ IR    OR │   │TrH+GrTh
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

module Grip()
{
   polygon
   ([
      // Grip
      [KegIR - GripThickness, (TrayHeight + GripThickness) - EdgeChamfer],    // 1 .. 2
      [(KegIR - GripThickness) + EdgeChamfer, TrayHeight + GripThickness],    // Chamf on 2
      [(KegOR + TrayThickness) - EdgeChamfer, TrayHeight + GripThickness],    // 2 .. 3
      [KegOR + TrayThickness , (TrayHeight + GripThickness) - EdgeChamfer],   // Chamf 3
      [KegOR + TrayThickness, 0],                                             // 3 .. 4

      [KegOR + EdgeChamfer, 0],                                               // 6 .. 7
      [KegOR, EdgeChamfer],                                                   // Chamf on 7
      // Grip + Spongeholder
      [KegOR, TrayHeight - EdgeChamfer],                                      // 7 ..8
      [KegOR - EdgeChamfer, TrayHeight],                                      // Chamf on 8
      [KegIR + EdgeChamfer, TrayHeight],                                      // 8 .. 9
      [KegIR, TrayHeight - EdgeChamfer],                                      // Chamf on 9
      [KegIR, HookGripHeight + EdgeChamfer],                                  // 9 .. 10
      [KegIR - EdgeChamfer, HookGripHeight],                                  // Chamf on 10
      [(KegIR - GripThickness) + EdgeChamfer, HookGripHeight],                // 10 .. 1
      [KegIR - GripThickness, HookGripHeight + EdgeChamfer]                   // Chamf on 1
   ]);
}

module Tray()
{
   polygon
   ([
      [KegOR, SpongeThickness],                                               // 4
      // Spongeholder
      [TrayOR - EdgeChamfer, SpongeThickness],                                // 4 .. 5
      [TrayOR, SpongeThickness - EdgeChamfer],                                // Chamf on 5
      [TrayOR, EdgeChamfer],                                                  // 5 .. 6
      [TrayOR - EdgeChamfer, 0],                                              // Chamf on 6
      [KegOR + EdgeChamfer, 0],                                               // 6 .. 7
      [KegOR, EdgeChamfer],                                                   // Chamf on 7
      // Grip + Spongeholder
      [KegOR, TrayHeight - EdgeChamfer],                                      // 7 ..8
   ]);
}

// Outline of drip catcher
module KegDripCatcherBody()
{

Tray();
Grip();

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

module COHolder()
{
   // Angular step repetition out of 360deg
   AngularRepeat = (360 * GasDiameter) / (Pi * KegOR * 2);
   
   difference()
   {
      // Tray
      rotate_extrude(angle=AngularRepeat) KegDripCatcherBody();

      #CreateText("ZETA", size = 9, position = [KegOR - (KegRimThickness / 2), 10, (TrayHeight + GripThickness) - 3 + RenderCludge]);
   }
}

// ###########################################

if( Model == "DT" )
   KegDripCatcher();
else if( Model == "CO" )
   COHolder();
