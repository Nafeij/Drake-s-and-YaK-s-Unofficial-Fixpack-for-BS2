package game.gui
{
   import engine.saga.convo.Convo;
   import engine.saga.convo.ConvoCursor;
   
   public interface IGuiConvo
   {
       
      
      function init(param1:IGuiContext, param2:Convo, param3:Boolean) : void;
      
      function set convo(param1:Convo) : void;
      
      function showConvoCursor(param1:ConvoCursor) : void;
      
      function setConvoRect(param1:Number, param2:Number, param3:Number, param4:Number) : void;
      
      function showConvoCursorButton(param1:Boolean) : void;
      
      function cleanup() : void;
      
      function get ready() : Boolean;
      
      function getDebugString() : String;
   }
}
