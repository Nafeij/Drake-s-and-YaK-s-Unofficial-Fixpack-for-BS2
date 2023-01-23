package engine.achievement
{
   import engine.core.locale.Localizer;
   
   public class AchievementDef
   {
       
      
      public var id:String;
      
      public var type:AchievementType;
      
      public var count:int;
      
      public var iconUrl:String;
      
      public var renownAwardAmount:int;
      
      public var progressVar:String;
      
      public var progressCount:int;
      
      public var local:Boolean;
      
      private var _name:String;
      
      private var _description:String;
      
      public function AchievementDef()
      {
         super();
      }
      
      public function get description() : String
      {
         return this._description;
      }
      
      public function set description(param1:String) : void
      {
         this._description = param1;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         if(this._name == param1)
         {
            return;
         }
         this._name = param1;
      }
      
      public function toString() : String
      {
         return this.id;
      }
      
      public function localizeAchievementDef(param1:Localizer) : void
      {
         if(param1)
         {
            this.name = param1.translate(this.id);
            this.description = param1.translate(this.id + "_description");
         }
         else
         {
            this.name = this.id;
            this.description = "";
         }
      }
   }
}
