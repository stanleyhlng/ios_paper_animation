ios_paper_animation
===================

[prototyping] Paper Animation iOS App

This is an iOS prototyping application for Paper navigation.

## Walkthrough of all user stories
[![image](https://raw.githubusercontent.com/wiki/stanleyhlng/ios_paper_animation/assets/ios_paper_animation.gif)](https://raw.githubusercontent.com/wiki/stanleyhlng/ios_paper_animation/assets/ios_paper_animation.gif)

## Completed user stories
 * [x] Dragging the headline should reveal the menu
 * [x] If you're dragging down, releasing the headline should animate the headline to the down position
 * [x] If you're dragging up, releasing the headline should animate the headline to the up position
 * [x] If you're dragging the headline up past the top, the friction should increase
 * [x] Optional: Fade in different headlines every few seconds
 * [x] Optional: Dragging on the scrollable feed of headlines should change the scale of the feed

## Time spent
10 hours spent in total

## Learnings
 * Animation
   * Animation of properties such as color, frame, and alpha
   * Animation options such as repeat and reverse
   * Damping ratio and spring velocity
   * Working with affine transforms
 * Gestures
   * Attaching gestures to views
   * Accessing location, velocity, rotation, and scale
   * Processing gesture state

 * Objective-C
   * NSStringFromCGRect
```
    CGRect title = self.sectionCoverTitleView.frame;
    NSLog(@"title %@", NSStringFromCGRect(title));
```
    
## Libraries
```
platform :ios, '7.0'
pod 'TTTAttributedLabel'
pod 'AVHexColor', '~> 1.2.0'
pod 'Reveal-iOS-SDK'
```
