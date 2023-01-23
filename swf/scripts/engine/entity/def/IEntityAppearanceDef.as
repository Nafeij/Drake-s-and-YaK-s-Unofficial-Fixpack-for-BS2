package engine.entity.def
{
   public interface IEntityAppearanceDef
   {
       
      
      function get portraitUrl() : String;
      
      function get backPortraitUrl() : String;
      
      function get versusPortraitUrl() : String;
      
      function get promotePortraitUrl() : String;
      
      function get soundsUrl() : String;
      
      function get animsUrl() : String;
      
      function get vfxUrl() : String;
      
      function getIconUrl(param1:EntityIconType) : String;
      
      function setIconUrl(param1:EntityIconType, param2:String) : void;
      
      function get baseIconUrl() : String;
      
      function get unlock_id() : String;
      
      function get acquire_id() : String;
      
      function get backPortraitOffset() : int;
      
      function get portraitFoley() : String;
      
      function get id() : String;
      
      function get entityClass() : IEntityClassDef;
      
      function hasIcons() : Boolean;
      
      function clone() : IEntityAppearanceDef;
   }
}
