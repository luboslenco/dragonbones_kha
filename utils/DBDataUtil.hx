package dragonbones.utils;
import dragonbones.animation.TimelineState;
import dragonbones.objects.AnimationData;
import dragonbones.objects.ArmatureData;
import dragonbones.objects.DBTransform;
import dragonbones.objects.Frame.TransformFrame;
import dragonbones.objects.SlotData;
import dragonbones.objects.Timeline.TransformTimeline;
import dragonbones.utils.TransformUtil;
import dragonbones.flash.Point;

/**
 * @author SlavaRa
 * kha port by @luboslenco
 */
class DBDataUtil {
	
	static var _helpTransform1:DBTransform = new DBTransform();
	static var _helpTransform2:DBTransform = new DBTransform();
	
	public static inline function transformArmatureData(armatureData:ArmatureData) {
		var list = armatureData.boneDataList;
		var i = list.length;
		while(i --> 0) {
			var data = list[i];
			if(data.parent == null) {
				continue;
			}
			var parentBoneData = armatureData.getBoneData(data.parent);
			if(parentBoneData != null) {
				data.transform.copy(data.global);
				TransformUtil.transformPointWithParent(data.transform, parentBoneData.global);
			}
		}
	}
	
	public static inline function transformArmatureDataAnimations(armatureData:ArmatureData) {
		var list = armatureData.animationDataList;
		var i = list.length;
		while(i --> 0) {
			transformAnimationData(list[i], armatureData);
		}
	}
	
	public static inline function transformAnimationData(animationData:AnimationData, armatureData:ArmatureData) {
		var skinData = armatureData.getSkinData(null);
		var boneDataList = armatureData.boneDataList;
		var slotDataList = skinData.slotDataList;
		var i = boneDataList.length;
		var parentTimeline:TransformTimeline;
		var it:TransformFrame;
		while(i --> 0) {
			var boneData = boneDataList[i];
			var timeline = animationData.getTimeline(boneData.name);
			if(timeline == null) {
				continue;
			}
			
			var slotData:SlotData = null;
			for(it in slotDataList) {
				slotData = it;
				if(it.parent == boneData.name) {
					break;
				}
			}
			
			var parentTimeline = boneData.parent != null ? animationData.getTimeline(boneData.parent) : null;
			var frameList = timeline.frameList;
			var originTransform:DBTransform = null;
			var originPivot:Point = null;
			var prevFrame:TransformFrame = null;
			for(it in timeline.frameList) {
				var frame:TransformFrame = cast(it, TransformFrame);
				if(parentTimeline != null) {
					_helpTransform1.copy(frame.global);
					getTimelineTransform(parentTimeline, frame.position, _helpTransform2);
					TransformUtil.transformPointWithParent(_helpTransform1, _helpTransform2);
					frame.transform.copy(_helpTransform1);
				} else {
					frame.transform.copy(frame.global);
				}
				frame.transform.x -= boneData.transform.x;
				frame.transform.y -= boneData.transform.y;
				frame.transform.skewX -= boneData.transform.skewX;
				frame.transform.skewY -= boneData.transform.skewY;
				frame.transform.scaleX -= boneData.transform.scaleX;
				frame.transform.scaleY -= boneData.transform.scaleY;
				if(!timeline.transformed && slotData != null) {
					frame.zOrder -= slotData.zOrder;
				}
				if(originTransform == null) {
					originTransform = timeline.originTransform;
					originTransform.copy(frame.transform);
					originTransform.skewX = TransformUtil.formatRadian(originTransform.skewX);
					originTransform.skewY = TransformUtil.formatRadian(originTransform.skewY);
					originPivot = timeline.originPivot;
					//originPivot.copyFrom(frame.pivot);
					originPivot.setTo(frame.pivot.x, frame.pivot.y);
				}
				frame.transform.x -= originTransform.x;
				frame.transform.y -= originTransform.y;
				frame.transform.skewX = TransformUtil.formatRadian(frame.transform.skewX - originTransform.skewX);
				frame.transform.skewY = TransformUtil.formatRadian(frame.transform.skewY - originTransform.skewY);
				frame.transform.scaleX -= originTransform.scaleX;
				frame.transform.scaleY -= originTransform.scaleY;
				if(!timeline.transformed) {
					frame.pivot.x -= originPivot.x;
					frame.pivot.y -= originPivot.y;
				}
				if(prevFrame != null) {
					var dLX = frame.transform.skewX - prevFrame.transform.skewX;
					if(prevFrame.tweenRotate != 0) {
						if(prevFrame.tweenRotate > 0) {
							if(dLX < 0) {
								frame.transform.skewX += ConstValues.DOUBLE_PI;
								frame.transform.skewY += ConstValues.DOUBLE_PI;
							}
							if(prevFrame.tweenRotate > 1) {
								frame.transform.skewX += ConstValues.DOUBLE_PI * (prevFrame.tweenRotate - 1);
								frame.transform.skewY += ConstValues.DOUBLE_PI * (prevFrame.tweenRotate - 1);
							}
						} else {
							if(dLX > 0) {
								frame.transform.skewX -= ConstValues.DOUBLE_PI;
								frame.transform.skewY -= ConstValues.DOUBLE_PI;
							}
							if(prevFrame.tweenRotate < 1) {
								frame.transform.skewX += ConstValues.DOUBLE_PI * (prevFrame.tweenRotate + 1);
								frame.transform.skewY += ConstValues.DOUBLE_PI * (prevFrame.tweenRotate + 1);
							}
						}
					} else {
						frame.transform.skewX = prevFrame.transform.skewX + TransformUtil.formatRadian(frame.transform.skewX - prevFrame.transform.skewX);
						frame.transform.skewY = prevFrame.transform.skewY + TransformUtil.formatRadian(frame.transform.skewY - prevFrame.transform.skewY);
					}
				}
				prevFrame = frame;
			}
			timeline.transformed = true;
		}
	}
	
	public static inline function getTimelineTransform(timeline:TransformTimeline, position:Float, result:DBTransform) {
		var frameList = timeline.frameList;
		var i = frameList.length;
		while(i --> 0) {
			var currentFrame:TransformFrame = cast(frameList[i], TransformFrame);
			if(currentFrame.position <= position && (currentFrame.position + currentFrame.duration) > position) {
				var tweenEasing = currentFrame.tweenEasing;
				if(i == (frameList.length - 1) || tweenEasing != tweenEasing || position == currentFrame.position) {
					result.copy(currentFrame.global); 
				} else {
					var progress = (position - currentFrame.position) / currentFrame.duration;
					if(tweenEasing != 0) {
						progress = TimelineState.getEaseValue(progress, tweenEasing);
					}
					var nextFrame:TransformFrame = cast(frameList[i + 1], TransformFrame);
					result.x = currentFrame.global.x + (nextFrame.global.x - currentFrame.global.x) * progress;
					result.y = currentFrame.global.y + (nextFrame.global.y - currentFrame.global.y) * progress;
					result.skewX = TransformUtil.formatRadian(currentFrame.global.skewX + (nextFrame.global.skewX - currentFrame.global.skewX) * progress);
					result.skewY = TransformUtil.formatRadian(currentFrame.global.skewY + (nextFrame.global.skewY - currentFrame.global.skewY) * progress);
					result.scaleX = currentFrame.global.scaleX + (nextFrame.global.scaleX - currentFrame.global.scaleX) * progress;
					result.scaleY = currentFrame.global.scaleY + (nextFrame.global.scaleY - currentFrame.global.scaleY) * progress;
				}
				break;
			}
		}
	}
	
	public static inline function addHideTimeline(animationData:AnimationData, armatureData:ArmatureData) {
		for(it in armatureData.boneDataList) {
			var name = it.name;
			if(animationData.getTimeline(name) == null) {
				animationData.addTimeline(TransformTimeline.HIDE_TIMELINE, name);
			}
		}
	}
}
