package game.entry
{
   import engine.core.util.AppInfo;
   import engine.core.util.CloudSave;
   import game.cfg.GameConfig;
   import game.view.GameWrapper;
   
   public interface IEntryHelperDesktop
   {
       
      
      function get entry() : GameEntryDesktop;
      
      function init(param1:GameEntryDesktop) : void;
      
      function setup() : void;
      
      function initWrapper(param1:GameWrapper) : void;
      
      function startWrapper(param1:GameWrapper, param2:int) : void;
      
      function getAnalyticsInfo() : Vector.<String>;
      
      function processArgument(param1:String) : Boolean;
      
      function initCloudSave(param1:GameConfig, param2:AppInfo) : CloudSave;
      
      function get betaBranch() : String;
      
      function get userId() : String;
   }
}
