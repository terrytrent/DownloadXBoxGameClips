$PWD = "."
#rm -Force $PWD\TestClassOne*
$Assem=("System","System.Drawing","System.Windows.Forms")

$Source = @"
using System;
using System.Drawing;
using System.Windows.Forms;

namespace CustomCursor7
{
    public class Form6 : System.Windows.Forms.Form
    {
        [STAThread]
        static void Main() 
        {
            Application.Run(new Form6());
        }

        public Form6()
        {
            this.ClientSize = new System.Drawing.Size(292, 266);
            this.Text = "Cursor Example";

            // The following generates a cursor from an embedded resource.

            // To add a custom cursor, create a bitmap
            //        1. Add a new cursor file to your project: 
            //                Project->Add New Item->General->Cursor File

            // --- To make the custom cursor an embedded resource  ---

            // In Visual Studio:
            //        1. Select the cursor file in the Solution Explorer
            //        2. Choose View->Properties.
            //        3. In the properties window switch "Build Action" to "Embedded Resources"

            // On the command line:
            //        Add the following flag:
            //            /res:CursorFileName.cur,Namespace.CursorFileName.cur
            //        
            //        Where "Namespace" is the namespace in which you want to use the cursor
            //        and   "CursorFileName.cur" is the cursor filename.

            // The following line uses the namespace from the passed-in type
            // and looks for CustomCursor.MyCursor.Cur in the assemblies manifest.
	    // NOTE: The cursor name is acase sensitive.
            this.Cursor = new Cursor(GetType(), "MyCursor.cur");  

        }
    }
}
"@
$source | Out-File CustomCursor7.cs
Add-Type -ReferencedAssemblies $Assem -OutputAssembly $PWD\CustomCursor7.dll -OutputType Library -Path $PWD\CustomCursor7.cs
Add-Type -Path $PWD\CustomCursor7.dll -ReferencedAssemblies $assem
$tes=New-Object 

CustomCursor


Add-Type -OutputAssembly $PWD\TestClassOne.dll -OutputType Library -Path $PWD\tcone.cs

Add-Type -Path $PWD\TestClassOne.dll

$a = New-Object TEST.TestClassOne
"Using TestClassOne"
$a.DoNothing()