import Foundation

enum UIConstants {
    static let trackerCollectionViewLabel = NSLocalizedString("UIConstants.trackerCollectionViewLabel", comment: "Трекеры")
    static let statisticsViewLabel = NSLocalizedString("UIConstants.statisticsViewLabel", comment: "Статистика")
}

enum UITrackersVCConstants {
    static let title = NSLocalizedString("UITrackersVCConstants.title", comment: "Трекеры")
    static let clearTextLabel = NSLocalizedString("UITrackersVCConstants.clearTextLabel", comment: "Что будем отслеживать?")
    static let searchBarPlaceholder = NSLocalizedString("UITrackersVCConstants.searchBarPlaceholder", comment: "Поиск")
}

enum UIHabitTrackerConstants {
    static let errorMessage = NSLocalizedString("UIHabitTrackerConstants.errorMessage", comment: "Ограничение 38 символов")
    static let sectionCategory = NSLocalizedString("UIHabitTrackerConstants.sectionCategory", comment: "Категория")
    static let sectionSchedule = NSLocalizedString("UIHabitTrackerConstants.sectionSchedule", comment: "Расписание")
    static let categoryImportant = NSLocalizedString("UIHabitTrackerConstants.categoryImportant", comment: "Важное")
    static let categoryUnimportant = NSLocalizedString("UIHabitTrackerConstants.categoryUnimportant", comment: "Неважное")
    static let title = NSLocalizedString("UIHabitTrackerConstants.title", comment: "Новая привычка")
    static let namePlaceholder = NSLocalizedString("UIHabitTrackerConstants.namePlaceholder", comment: "Введите название трекера")
    static let createButtonLabel = NSLocalizedString("UIHabitTrackerConstants.createButtonLabel", comment: "Создать")
    static let cancelButtonLabel = NSLocalizedString("UIHabitTrackerConstants.cancelButtonLabel", comment: "Отменить")
    static let emojiTitle = NSLocalizedString("UIHabitTrackerConstants.emojiTitle", comment: "Emoji")
    static let colorTitle = NSLocalizedString("UIHabitTrackerConstants.colorTitle", comment: "Цвет")
    static let everyDay = NSLocalizedString("UIHabitTrackerConstants.everyDay", comment: "Каждый день")
}

enum NewTrackerConstants{
    static let newTrackerTitleSymbolsLimit = 38
}

enum UIScheduleConstants {
    static let navigationTitle = NSLocalizedString("UIScheduleConstants.navigationTitle", comment: "Расписание")
    static let doneButtonTitle = NSLocalizedString("UIScheduleConstants.doneButtonTitle", comment: "Готово")
}

enum UICategoryConstants {
    static let navigationTitle = NSLocalizedString("UICategoryConstants.navigationTitle", comment: "Категория")
    static let addButtonTitle = NSLocalizedString("UICategoryConstants.addButtonTitle", comment: "Добавить категорию")
    static let clearTextLabel = NSLocalizedString("UICategoryConstants.clearTextLabel", comment: "Привычки и события можно\n объединить по смыслу")
    static let namePlaceholder = NSLocalizedString("UICategoryConstants.namePlaceholder", comment: "Введите название категории")
    static let title = NSLocalizedString("UICategoryConstants.title", comment: "Новая категория")
}

enum UUIOnboardingConstants {
    static let buttonTitle = NSLocalizedString("UUIOnboardingConstants.buttonTitle", comment: "Вот это технологии!")
    static let textOnboardingv1 = NSLocalizedString("UUIOnboardingConstants.textOnboardingv1", comment: "Отслеживайте только то, что хотите")
    static let textOnboardingv2 = NSLocalizedString("UUIOnboardingConstants.textOnboardingv2", comment: "Даже если это\nне литры воды и йога")
}
