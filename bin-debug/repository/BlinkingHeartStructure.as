import com.greensock.TweenMax;
import com.greensock.TimelineLite;
import com.greensock.easing.*;

import mx.utils.Delegate;

class BlinkingHeartStructure extends MovieClip {
	public var ignoreDelay:Boolean = false;

	public function BlinkingHeartStructure() {
		play();
	}
	
	public function stop():Void {
		TweenMax.killTweensOf(this);
	}
	
	public function play():Void {
		TweenMax.killTweensOf(this);
		_alpha = 0;
		var delay = (20 - (_parent._currentframe % 20)) % 20;

		if(ignoreDelay)
			delay = 0;
			
		TweenMax.to(this, 10, {_alpha : 100, useFrames: true, yoyo : true, delay: delay, repeat: -1 , easing: Linear.easeNone});
	}
}

