/* [Model to Generate] */
// Select which model to generate
Model="DT"; // [DT:Drip Catcher, CO2:CO2 Holder]
// Material Thickness
MaterialThickness = 10;
// Chamfers
EdgeChamfer = 5;

/* [Keg Parameters] */
// Keg - Outer Diameter
KegOD = 205;
// Keg - Rim Thickness
KegRimThickness = 25;

/* [Grip Parameters] */
// Grip - Height
GripHeight = 20;
// Grip - AttachmentHeight
AttachmentHeight = 50;

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
// Neck - Diameter
GasNeckDiameter = 25;
// Regulator - Rest Diameter
RegulatorRestDiameter = 50;

// ###########################################

/* [Hidden] */
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
HookGripHeight = AttachmentHeight - GripHeight;

// Tray - Outer R
TrayOR = KegOR + SpongeDepth;

// SpongeHolder
SpongeHolderInside = KegOR + MaterialThickness;
SpongeHolderOutside = TrayOR - MaterialThickness;

// CO2 - Outer R
CO2OR = KegOR + GasDiameter;

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
      [KegIR - MaterialThickness, (AttachmentHeight + MaterialThickness) - EdgeChamfer],
      [(KegIR - MaterialThickness) + EdgeChamfer, AttachmentHeight + MaterialThickness],
      [(KegOR + MaterialThickness) - EdgeChamfer, AttachmentHeight + MaterialThickness],
      [KegOR + MaterialThickness , (AttachmentHeight + MaterialThickness) - EdgeChamfer],
      [KegOR + MaterialThickness, 0],
      [KegOR + EdgeChamfer, 0],
      [KegOR, EdgeChamfer],

      [KegOR, AttachmentHeight - EdgeChamfer],
      [KegOR - EdgeChamfer, AttachmentHeight],
      [KegIR + EdgeChamfer, AttachmentHeight],
      [KegIR, AttachmentHeight - EdgeChamfer],
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
      [KegOR, AttachmentHeight - EdgeChamfer],
   ]);
}

module CO2Shelf()
{
   polygon
   ([
      [KegOR, GasDiameter],
      [CO2OR - EdgeChamfer, GasDiameter],
      [CO2OR, GasDiameter - EdgeChamfer],
      [CO2OR + (MaterialThickness * 2), EdgeChamfer],
      [CO2OR + (MaterialThickness * 2) - EdgeChamfer, 0],
      [KegOR + EdgeChamfer, 0],
      [KegOR, EdgeChamfer],
      [KegOR, AttachmentHeight - EdgeChamfer],
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
      
      #CreateText("ZETA", size = 9, position = [KegOR - (KegRimThickness / 2), 10, (AttachmentHeight + MaterialThickness) - 3 + RenderCludge]);
   }
}

// ###########################################

// Outline of CO2 Holder
module CO2HolderBody()
{
   CO2Shelf();
   Grip();
}

// Canister mount needs to be _min_ R from grip.
// Bad idea to hang using regulator?
module CO2Holder()
{
   // Angular step repetition out of 360deg
   AngularRepeat = (360 * GasDiameter) / (Pi * KegOR * 2);
   
   difference()
   {
      // Rotate the entire object to make calcs simple...
      rotate([0, 0, -AngularRepeat / 2])
      {
         difference()
         {
            rotate_extrude(angle=AngularRepeat) CO2HolderBody();

            #CreateText("ZETA", size = 9, position = [KegOR - (KegRimThickness / 2), 10, (AttachmentHeight + MaterialThickness) - 3 + RenderCludge]);
         }
      }
   
      translate([KegOR + MaterialThickness + (GasDiameter / 2), 0, - RenderCludge])
      {
         // Cut for bottle passthrough
         cylinder(h=(AttachmentHeight + MaterialThickness + RenderCludge), d=GasNeckDiameter);
         translate([0, 0, (MaterialThickness + (AttachmentHeight + MaterialThickness)/2)])
         {
            // Cut for regulator body
            cube([RegulatorRestDiameter, RegulatorRestDiameter, AttachmentHeight + MaterialThickness], center = true);
         
         translate([20, 0, 3])
            // Cut for gauge
            cube([RegulatorRestDiameter, RegulatorRestDiameter, AttachmentHeight + MaterialThickness], center = true);
         }
         
         translate([0, RegulatorRestDiameter - RenderCludge, (AttachmentHeight/2) + MaterialThickness + 5])
            // Cut for CO2 line
            cube([20, RegulatorRestDiameter, AttachmentHeight], center = true);
      }
   }
}

// ###########################################

if( Model == "DT" )
   KegDripCatcher();
else if( Model == "CO2" )
   CO2Holder();
