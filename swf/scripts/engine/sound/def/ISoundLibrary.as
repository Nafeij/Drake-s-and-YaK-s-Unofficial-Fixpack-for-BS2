package engine.sound.def
{
   public interface ISoundLibrary
   {
       
      
      function getSoundDef(param1:String) : ISoundDef;
      
      function get soundDefs() : Vector.<ISoundDef>;
      
      function getAllSoundDefs(param1:Vector.<ISoundDef>) : Vector.<ISoundDef>;
      
      function get sku() : String;
      
      function get url() : String;
   }
}
