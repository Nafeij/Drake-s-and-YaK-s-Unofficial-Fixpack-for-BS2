package engine.entity.def
{
   import engine.core.IDescribed;
   import engine.core.IId;
   import engine.core.INamed;
   import engine.math.Box;
   import engine.stat.def.IStatRangeOwner;
   
   public interface IEntityClassDef extends IId, INamed, IDescribed, IStatRangeOwner
   {
       
      
      function get parentEntityClass() : IEntityClassDef;
      
      function get allChildEntityClasses() : Vector.<IEntityClassDef>;
      
      function get playerOnlyChildEntityClasses() : Vector.<IEntityClassDef>;
      
      function get passive() : String;
      
      function get attacks() : Vector.<String>;
      
      function get actives() : Vector.<String>;
      
      function get additionalActives() : Vector.<String>;
      
      function get race() : String;
      
      function get bounds() : Box;
      
      function get shadowUrl() : String;
      
      function get disableShadow() : Boolean;
      
      function get propAnimUrl() : String;
      
      function get mobile() : Boolean;
      
      function get collidable() : Boolean;
      
      function get partyTag() : String;
      
      function getPartyTagLimit(param1:EntitiesMetadata) : int;
      
      function setPartyTagLimit(param1:EntitiesMetadata, param2:int) : void;
      
      function get partyTagDisplay() : String;
      
      function getEntityClassAppearanceDef(param1:int) : IEntityAppearanceDef;
      
      function getAppearanceName(param1:int) : String;
      
      function getAppearanceDesc(param1:int) : String;
      
      function get appearanceDefs() : Vector.<IEntityAppearanceDef>;
      
      function get playerClass() : Boolean;
      
      function get gender() : String;
      
      function get isWarped() : Boolean;
      
      function get hasSubmergedMove() : Boolean;
   }
}
