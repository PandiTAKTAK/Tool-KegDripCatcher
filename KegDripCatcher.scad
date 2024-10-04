/* [Model to Generate] */
// Select which model to generate
Model="DT"; // [DT:Drip Catcher, CO2:CO2 Holder]
// Material Thickness
MaterialThickness = 10;

/* [Keg Parameters] */
// Keg - Outer Diameter
KegOD = 205;
// Keg - Rim Thickness
KegRimThickness = 25;

/* [Tray Parameters] */
// Tray - Height
TrayHeight = 50;

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
SpongeHolderInside = KegOR + MaterialThickness;
SpongeHolderOutside = TrayOR - MaterialThickness;

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
      [KegIR - MaterialThickness, (TrayHeight + MaterialThickness) - EdgeChamfer],
      [(KegIR - MaterialThickness) + EdgeChamfer, TrayHeight + MaterialThickness],
      [(KegOR + MaterialThickness) - EdgeChamfer, TrayHeight + MaterialThickness],
      [KegOR + MaterialThickness , (TrayHeight + MaterialThickness) - EdgeChamfer],
      [KegOR + MaterialThickness, 0],
      [KegOR + EdgeChamfer, 0],
      [KegOR, EdgeChamfer],

      [KegOR, TrayHeight - EdgeChamfer],
      [KegOR - EdgeChamfer, TrayHeight],
      [KegIR + EdgeChamfer, TrayHeight],
      [KegIR, TrayHeight - EdgeChamfer],
      [KegIR, HookGripHeight + EdgeChamfer],
      [KegIR - EdgeChamfer, HookGripHeight],
      [(KegIR - MaterialThickness) + EdgeChamfer, HookGripHeight],
      [KegIR - MaterialThickness, HookGripHeight + EdgeChamfer]
   ]);
}

module Tray()
{
   polygon
   ([
      [KegOR, SpongeThickness],
      [TrayOR - EdgeChamfer, SpongeThickness],
      [TrayOR, SpongeThickness - EdgeChamfer],
      [TrayOR, EdgeChamfer],
      [TrayOR - EdgeChamfer, 0],
      [KegOR + EdgeChamfer, 0],
      [KegOR, EdgeChamfer],
      [KegOR, TrayHeight - EdgeChamfer],
   ]);
}

module CreateText(textString, size, position) {
    translate(position)
        linear_extrude(height = 3)
            text(textString, font = "Leelawadee UI:style=Bold", size = size, valign = "center", halign = "center");
}

// ###########################################

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
      [SpongeHolderOutside, MaterialThickness],
      [SpongeHolderInside, MaterialThickness]
   ]);
}

module KegDripCatcher()
{
   // Angular step repetition out of 360deg
   AngularRepeat = (360 * SpongeWidth) / (Pi * KegOR * 2);
   // Sponge cut
   SpongeCutAngularRepeat = (360 * MaterialThickness) / (Pi * TrayOR * 2);
   
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
      
      #CreateText("ZETA", size = 9, position = [KegOR - (KegRimThickness / 2), 10, (TrayHeight + MaterialThickness) - 3 + RenderCludge]);
   }
}

// ###########################################

// Outline of CO2 Holder
module CO2HolderBody()
{
   //Tray();
   Grip();
}

module CO2Holder()
{
   // Angular step repetition out of 360deg
   AngularRepeat = (360 * GasDiameter) / (Pi * KegOR * 2);
   
   difference()
   {
      // Tray
      rotate_extrude(angle=AngularRepeat) CO2HolderBody();

      #CreateText("ZETA", size = 9, position = [KegOR - (KegRimThickness / 2), 10, (TrayHeight + MaterialThickness) - 3 + RenderCludge]);
   }
}

// ###########################################

if( Model == "DT" )
   KegDripCatcher();
else if( Model == "CO2" )
   CO2Holder();
