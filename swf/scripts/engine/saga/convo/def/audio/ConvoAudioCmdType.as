package engine.saga.convo.def.audio
{
   import engine.core.util.Enum;
   
   public class ConvoAudioCmdType extends Enum
   {
      
      public static var START:ConvoAudioCmdType = new ConvoAudioCmdType("START",enumCtorKey);
      
      public static var END:ConvoAudioCmdType = new ConvoAudioCmdType("END",enumCtorKey);
      
      public static var MODIFY:ConvoAudioCmdType = new ConvoAudioCmdType("MODIFY",enumCtorKey);
       
      
      public function ConvoAudioCmdType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
