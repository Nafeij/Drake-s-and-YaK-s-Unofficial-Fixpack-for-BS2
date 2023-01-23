package engine.anim.def
{
   public interface IAnimClipDef
   {
       
      
      function get id() : String;
      
      function get durationMs() : int;
      
      function set numFrames(param1:int) : void;
      
      function get numFrames() : int;
      
      function get fps() : int;
      
      function get url() : String;
      
      function get offsetY() : Number;
      
      function get looping() : Boolean;
      
      function isSpriteSheeted() : Boolean;
      
      function get aframes() : AnimFrames;
      
      function get highQuality() : Boolean;
   }
}
