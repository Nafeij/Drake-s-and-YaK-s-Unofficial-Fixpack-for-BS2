package engine.gui
{
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.def.IEntityDef;
   
   public interface IGuiSpeechBubble
   {
       
      
      function init(param1:*, param2:IBattleEntity, param3:IEntityDef, param4:String, param5:Number, param6:Boolean) : void;
      
      function cleanup() : void;
      
      function set x(param1:Number) : void;
      
      function set y(param1:Number) : void;
   }
}
