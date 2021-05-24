
import UIKit
import OnboardKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let presentationAssembly = PresentationAssembly(serviceAssembly: ServicesAssembly(coreAssembly: CoreAssembly()))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        setupViewControllers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        let doOnboarding = defaults.bool(forKey: "doOnBoarding")
        defaults.set(!doOnboarding, forKey: "doOnBoarding")
        
        if !doOnboarding {
            let page1 = OnboardPage(title: "Добро пожаловать",
                                   imageName: "",
                                   description: "Здесь можно бегло ознакомиться с тем, что предлагает наше приложение:)")
            let page2 = OnboardPage(title: "Экран уведомлений",
                                   imageName: "messagesBig",
                                   description: "Места контактов и чаты по данным местам")
            let page3 = OnboardPage(title: "Радар",
                                   imageName: "radarBig",
                                   description: "Отображение контактов на карте с указанием уровня риска")
            let page4 = OnboardPage(title: "Статистика",
                                   imageName: "statsBig",
                                   description: "Количество контактов за месяц")
            let page5 = OnboardPage(title: "Настройки",
                                   imageName: "otherBig",
                                   description: "Подключение устройтва и настройки",
                                   advanceButtonTitle: "Конец)")
            let onboardingViewController = OnboardViewController(pageItems: [page1, page2, page3, page4, page5])
            onboardingViewController.presentFrom(self, animated: true)
        }
    }
    
    func setupViewControllers() {
        //home
        let conversationsInteractor =
            ConversationsInteractor(themeService: presentationAssembly.serviceAssembly.themeService,
                                    firebaseService: presentationAssembly.serviceAssembly.firebaseService,
                                    coreDataService: presentationAssembly.serviceAssembly.coreDataService)
        let conversationsVC = ConversationsViewController(conversationsInteractor: conversationsInteractor, presentationAssembly: presentationAssembly)
        
        let messagesNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "messages"), selectedImage: #imageLiteral(resourceName: "messages"), rootViewController: conversationsVC)
        
        //search
        let radarNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "radar"), selectedImage: #imageLiteral(resourceName: "radar"), rootViewController: RadarViewController())
        
        let statsNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "stats"), selectedImage: #imageLiteral(resourceName: "stats"), rootViewController: ChartViewController())
        
        let otherNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "other"), selectedImage: #imageLiteral(resourceName: "other"), rootViewController: BluetoothViewController())
        
        tabBar.tintColor = .black
        
        viewControllers = [messagesNavController,
                           radarNavController,
                           statsNavController,
                           otherNavController]
        
        //modify tab bar item insets
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }
}






