@echo off
REM Clean up project-specific content for combat engine template
REM This script removes test content while keeping the engine core

echo ======================================
echo Combat Engine Template Cleanup
echo ======================================
echo.

setlocal enabledelayedexpansion

cd /d "%~dp0"

echo Deleting test scenes...
if exist "Scenes\Battle_Arena3D_Test.tscn" del "Scenes\Battle_Arena3D_Test.tscn"
if exist "Scenes\Battle_Arena3D_Test.tscn.import" del "Scenes\Battle_Arena3D_Test.tscn.import"
echo  ✓ Test scenes deleted

echo.
echo Deleting test scripts...
if exist "Scripts\phone_ui_test.gd" del "Scripts\phone_ui_test.gd"
if exist "Scripts\phone_ui_test.gd.uid" del "Scripts\phone_ui_test.gd.uid"
if exist "Scripts\test_combat_gym.gd" del "Scripts\test_combat_gym.gd"
if exist "Scripts\test_combat_gym.gd.uid" del "Scripts\test_combat_gym.gd.uid"
if exist "Scripts\radial_menu_Test.gd" del "Scripts\radial_menu_Test.gd"
if exist "Scripts\radial_menu_Test.gd.uid" del "Scripts\radial_menu_Test.gd.uid"
echo  ✓ Test scripts deleted

echo.
echo Deleting translation files...
if exist "Chain Reaction.Duration.translation" del "Chain Reaction.Duration.translation"
if exist "Chain Reaction.Effect.translation" del "Chain Reaction.Effect.translation"
if exist "Chain Reaction.Element 2.translation" del "Chain Reaction.Element 2.translation"
if exist "Chain Reaction.Reaction.translation" del "Chain Reaction.Reaction.translation"
if exist "Chain Reaction.Role.translation" del "Chain Reaction.Role.translation"
if exist "Chain Reaction.csv" del "Chain Reaction.csv"
if exist "Chain Reaction.csv.import" del "Chain Reaction.csv.import"
echo  ✓ Translation files deleted

echo.
echo Deleting Art folder...
if exist "Art" rmdir /s /q "Art"
echo  ✓ Art folder deleted

echo.
echo Deleting Models folder...
if exist "Models" rmdir /s /q "Models"
echo  ✓ Models folder deleted

echo.
echo Deleting Exported_Code_Logs folder...
if exist "Exported_Code_Logs" rmdir /s /q "Exported_Code_Logs"
echo  ✓ Exported_Code_Logs folder deleted

echo.
echo Clearing resource folders...
if exist "Resources\Party" (
    rmdir /s /q "Resources\Party"
    mkdir "Resources\Party"
    echo .gitkeep > "Resources\Party\.gitkeep"
)
if exist "Resources\Moves" (
    rmdir /s /q "Resources\Moves"
    mkdir "Resources\Moves"
    echo .gitkeep > "Resources\Moves\.gitkeep"
)
if exist "Resources\Equipment" (
    rmdir /s /q "Resources\Equipment"
    mkdir "Resources\Equipment"
    echo .gitkeep > "Resources\Equipment\.gitkeep"
)
echo  ✓ Resource folders recreated with .gitkeep

echo.
echo ======================================
echo Cleanup complete!
echo ======================================
echo.
echo Next steps:
echo 1. Review the cleaned project in Godot
echo 2. Commit changes with: git add -A
echo 3. Create branch: git checkout -b combat-engine-template
echo 4. Push: git push origin combat-engine-template
echo.
pause
