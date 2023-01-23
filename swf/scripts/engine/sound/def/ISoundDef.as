package engine.sound.def
{
   import flash.utils.Dictionary;
   
   public interface ISoundDef
   {
       
      
      function get soundName() : String;
      
      function get sku() : String;
      
      function get eventName() : String;
      
      function get isStream() : Boolean;
      
      function get debugString() : String;
      
      function get allowDuplicateSounds() : Boolean;
      
      function hasParameter(param1:String) : Boolean;
      
      function hasParameterValue(param1:String) : Boolean;
      
      function getParameterValue(param1:String) : Number;
      
      function get parameterValues() : Dictionary;
      
      function updateSku(param1:String) : void;
   }
}
