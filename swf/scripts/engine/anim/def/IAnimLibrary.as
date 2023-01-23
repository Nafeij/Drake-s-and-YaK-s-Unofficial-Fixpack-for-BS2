package engine.anim.def
{
   import engine.anim.view.IAnim;
   import flash.utils.Dictionary;
   
   public interface IAnimLibrary
   {
       
      
      function getAnimMix(param1:String, param2:String, param3:Function) : OrientedAnimMix;
      
      function getAnim(param1:String, param2:String, param3:Function, param4:Function) : IAnim;
      
      function getAnimDef(param1:String, param2:String) : IAnimDef;
      
      function hasOrientedAnims(param1:String, param2:String) : Boolean;
      
      function getOrientedAnims(param1:String, param2:String, param3:Function, param4:Function) : OrientedAnims;
      
      function getLoco(param1:String) : AnimLoco;
      
      function get url() : String;
      
      function get offsetsByFacing() : Dictionary;
      
      function get animsScale() : Number;
      
      function get animsAlpha() : Number;
      
      function get animsColor() : uint;
      
      function findDefaultAmbientMix() : String;
   }
}
