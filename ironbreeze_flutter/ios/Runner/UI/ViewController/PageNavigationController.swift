//
//  PageNavigationController.swift
//  Runner
//
//  Created by Perry Shalom on 23/01/2019.
//  Copyright © 2019 perrchick. All rights reserved.
//

import UIKit

class PageNavigationController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    static private(set) weak var shared: PageNavigationController?

    lazy var mapViewController: MapViewController = MapViewController.instantiate()
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [AppDelegate.shared.flutterViewController,
                mapViewController]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        PageNavigationController.shared = self

        delegate = self

        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.barStyle = .blackOpaque
    }

    func enableScrollingGesture(isEnabled: Bool) {
        // This line enables scrolling gesture, to disable user gestures simply don't assign
        dataSource = isEnabled ? self : nil
    }

    func goToPreviousPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        if let currentViewController = viewControllers?[0] {
            if let nextPage = pageViewController(self, viewControllerBefore: currentViewController) {
                setViewControllers([nextPage], direction: .reverse, animated: animated, completion: completion)
            }
        }
    }
    
    func goToNextPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        if let currentViewController = viewControllers?[0] {
            if let nextPage = pageViewController(self, viewControllerAfter: currentViewController) {
                setViewControllers([nextPage], direction: .forward, animated: animated, completion: completion)
            }
        }
    }
    
    func toggleMap() {
        if viewControllers?.first is MapViewController {
            enableScrollingGesture(isEnabled: false)
            goToPreviousPage()
        } else {
            //(orderedViewControllers[safe: 1] as? MapViewController).enable
            enableScrollingGesture(isEnabled: true)
            goToNextPage()
        }
    }

    func showMap() {
        if viewControllers?.first is FlutterViewController {
            enableScrollingGesture(isEnabled: true)
            goToNextPage()
        }
    }

    func showMainScreen() {
        if viewControllers?.first is MapViewController {
            enableScrollingGesture(isEnabled: false)
            goToPreviousPage()
        }
    }

    //MARK: - UIPageViewControllerDelegate

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            PerrFuncs.runOnUiThread { // DO NOT REMOVE
                // Prevents this crash: __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__
                self.enableScrollingGesture(isEnabled: false)
            }
        }
    }

    //MARK: - UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return orderedViewControllers[nextIndex]
    }
}
