package game.gui
{
   import engine.stat.def.StatType;
   import engine.stat.model.Stats;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class GuiStatsTooltip extends MovieClip
   {
       
      
      private var _armor_text:TextField;
      
      private var _str_text:TextField;
      
      private var _will_text:TextField;
      
      private var _exertion_text:TextField;
      
      private var _break_text:TextField;
      
      public function GuiStatsTooltip()
      {
         super();
         this._armor_text = getChildByName("armor_text") as TextField;
         this._str_text = getChildByName("strength_text") as TextField;
         this._will_text = getChildByName("will_text") as TextField;
         this._exertion_text = getChildByName("exertion_text") as TextField;
         this._break_text = getChildByName("break_text") as TextField;
         this.mouseEnabled = false;
      }
      
      private function getTextField(param1:String) : TextField
      {
         return getChildByName(param1) as TextField;
      }
      
      public function cleanup() : void
      {
      }
      
      public function setEntityValues(param1:Stats) : void
      {
         if(!param1)
         {
            visible = false;
            return;
         }
         if(this._armor_text)
         {
            this._armor_text.text = param1.getStat(StatType.ARMOR).value.toString();
         }
         if(this._str_text)
         {
            this._str_text.text = param1.getStat(StatType.STRENGTH).value.toString();
         }
         if(this._will_text)
         {
            this._will_text.text = param1.getStat(StatType.WILLPOWER).value.toString();
         }
         if(this._exertion_text)
         {
            this._exertion_text.text = param1.getStat(StatType.EXERTION).value.toString();
         }
         if(this._break_text)
         {
            this._break_text.text = param1.getStat(StatType.ARMOR_BREAK).value.toString();
         }
      }
   }
}
