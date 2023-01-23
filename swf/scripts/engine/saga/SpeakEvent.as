package engine.saga
{
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.def.IEntityDef;
   import flash.events.Event;
   
   public class SpeakEvent extends Event
   {
      
      public static const TYPE:String = "SpeakEvent.TYPE";
       
      
      public var speakerEnt:IBattleEntity;
      
      public var speakerDef:IEntityDef;
      
      public var msg:String;
      
      public var timeout:Number;
      
      public var anchor:String;
      
      public var direction:String;
      
      public var notranslate:Boolean;
      
      public function SpeakEvent(param1:IBattleEntity, param2:IEntityDef, param3:String, param4:Number, param5:String, param6:String, param7:Boolean)
      {
         super(TYPE);
         this.speakerEnt = param1;
         this.speakerDef = param2;
         this.msg = param3;
         this.timeout = param4;
         this.anchor = param5;
         this.direction = param6;
         this.notranslate = param7;
      }
      
      override public function toString() : String
      {
         return "anchor=" + this.anchor + ", msg=" + this.msg;
      }
   }
}
