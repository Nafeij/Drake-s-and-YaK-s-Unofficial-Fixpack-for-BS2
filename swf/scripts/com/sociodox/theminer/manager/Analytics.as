package com.sociodox.theminer.manager
{
   import com.google.analytics.AnalyticsTracker;
   import com.google.analytics.GATracker;
   import com.google.analytics.core.Domain;
   import com.google.analytics.core.DomainNameMode;
   import com.sociodox.theminer.window.Configuration;
   import flash.sampler.pauseSampling;
   import flash.sampler.startSampling;
   
   public class Analytics
   {
      
      private static var AnalyticTracker:AnalyticsTracker;
       
      
      public function Analytics()
      {
         super();
      }
      
      public static function Init() : void
      {
      }
      
      public static function Report(param1:String) : void
      {
         var _loc2_:Boolean = false;
         _loc2_ = Configuration.IsSamplingRequired();
         if(_loc2_)
         {
            pauseSampling();
         }
         if(Configuration.ANALYTICS_ENABLED)
         {
            if(AnalyticTracker == null && Stage2D != null)
            {
               AnalyticTracker = new GATracker(Stage2D,"UA-16424556-5","AS3",false);
               AnalyticTracker.setSampleRate(100);
               AnalyticTracker.setDomainName(new Domain(DomainNameMode.custom,"theminer.sociodox.com").name);
               AnalyticTracker.setDetectTitle(false);
               AnalyticTracker.setClientInfo(false);
               AnalyticTracker.setCampaignTrack(false);
               AnalyticTracker.config.detectTitle = false;
               AnalyticTracker.config.idleTimeout = 999999;
               AnalyticTracker.config.detectTitle = false;
            }
            if(AnalyticTracker)
            {
               AnalyticTracker.trackPageview(param1);
            }
         }
         if(_loc2_)
         {
            startSampling();
         }
      }
      
      public static function Track(param1:String, param2:String, param3:String = null, param4:Number = NaN) : void
      {
         var _loc5_:Boolean = false;
         _loc5_ = Configuration.IsSamplingRequired();
         if(_loc5_)
         {
            pauseSampling();
         }
         if(Configuration.ANALYTICS_ENABLED)
         {
            if(AnalyticTracker == null && Stage2D != null)
            {
               AnalyticTracker = new GATracker(Stage2D,"UA-16424556-5","AS3",false);
               AnalyticTracker.setSampleRate(100);
               AnalyticTracker.setDomainName(new Domain(DomainNameMode.custom,"theminer.sociodox.com").name);
               AnalyticTracker.setDetectTitle(false);
               AnalyticTracker.setClientInfo(false);
               AnalyticTracker.setCampaignTrack(false);
               AnalyticTracker.config.detectTitle = false;
               AnalyticTracker.config.idleTimeout = 999999;
               AnalyticTracker.config.detectTitle = false;
            }
            if(AnalyticTracker)
            {
               AnalyticTracker.trackEvent(param1,param2,param3,param4);
            }
         }
         if(_loc5_)
         {
            startSampling();
         }
      }
   }
}
