package engine.automator
{
   public class AutomatedProgramLineCtor
   {
       
      
      public function AutomatedProgramLineCtor()
      {
         super();
      }
      
      public static function ctor(param1:AutomatedProgram, param2:int, param3:String) : AutomatedProgramLine
      {
         var verb:String;
         var program:AutomatedProgram = param1;
         var num:int = param2;
         var str:String = param3;
         var argv:Array = str.split(" ");
         if(argv.length < 1)
         {
            throw new ArgumentError("Invalid program line string [" + str + "]");
         }
         verb = argv[0];
         try
         {
            switch(verb)
            {
               case "wait":
                  return new AutomatedProgramLine_Wait(program,num,str,argv);
               case "key":
                  return new AutomatedProgramLine_Key(program,num,str,argv);
               case "click":
                  return new AutomatedProgramLine_Click(program,num,str,argv);
               case "ff":
                  return new AutomatedProgramLine_FastForward(program,num,str,argv);
               case "exit":
                  return new AutomatedProgramLine_Exit(program,num,str,argv);
            }
         }
         catch(e:Error)
         {
            throw new ArgumentError("Error constructiong program line:\n" + e.getStackTrace());
         }
         throw new ArgumentError("Unknown program line verb: [" + verb + "]");
      }
   }
}
